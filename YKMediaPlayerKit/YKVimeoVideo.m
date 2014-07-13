//
//  VimeoVideo.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 3/13/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKVimeoVideo.h"

NSString *const kVideoConfigURL = @"http://player.vimeo.com/video/%@/config";

@interface YKVimeoVideo()
@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, strong) MPMoviePlayerViewController *player;
@end

@implementation YKVimeoVideo

#pragma mark - YKVideo Protocol

- (instancetype)initWithContent:(NSURL *)contentURL {
    self = [super init];
    if (self) {
        self.contentURL = contentURL;
    }
    return self;
}

- (void)parseWithCompletion:(void(^)(NSError *))callback {
    NSAssert(self.contentURL, @"Invalid contentURL");
    NSAssert(self.videoID, @"Vimeo URL is invalid");
    
    BOOL (^callback_if_error)(NSError *) = ^(NSError *error){
        if (error) {
            if (callback) {
                dispatch_async(dispatch_get_main_queue(), ^{ callback(error); });
            }
            return YES;
        }
        return NO;
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSString *dataURL = [NSString stringWithFormat:kVideoConfigURL, self.videoID];
        NSString *data = [NSString stringWithContentsOfURL:[NSURL URLWithString:dataURL] encoding:NSUTF8StringEncoding error:&error];
        
        if (callback_if_error(error)) return;
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
        
        if (callback_if_error(error)) return;
        
        self.videos = [jsonData valueForKeyPath:@"request.files.h264"];
        self.thumbs = [jsonData valueForKeyPath:@"video.thumbs"];

        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    });
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *, NSError *))callback {
    NSAssert(callback, @"usingBlock cannot be nil");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[self thumbURL:quality]];
        UIImage *thumbnail = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(thumbnail, nil);
        });
    });
}

- (NSURL *)videoURL:(YKQualityOptions)quality {
    NSDictionary *data = nil;
    
    switch (quality) {
        case YKQualityLow:
            data = self.videos[@"mobile"];
            break;
        case YKQualityMedium:
            data = self.videos[@"ds"];
            break;
        case YKQualityHigh:
            data = self.videos[@"hd"];
    }
    
    if (!data && self.videos.count > 0) {
        data = [self.videos allValues][0]; //defaults to 1st index
    }
    
    return data ? [NSURL URLWithString:data[@"url"]] : nil;
}

- (NSURL *)thumbURL:(YKQualityOptions)quality {
    NSString *strURL = nil;
    
    switch (quality) {
        case YKQualityLow:
            strURL = self.thumbs[@"640"];
            break;
        case YKQualityMedium:
            strURL = self.thumbs[@"960"];
            break;
        case YKQualityHigh:
            strURL = self.thumbs[@"1280"];
    }
    
    if (!strURL && self.thumbs.count > 0) {
        strURL = [self.thumbs allValues][0]; //defaults to 1st index
    }
    
    return strURL ? [NSURL URLWithString:strURL] : nil;
}

- (MPMoviePlayerViewController *)movieViewController:(YKQualityOptions)quality {
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[self videoURL:quality]];
    [self.player.moviePlayer setShouldAutoplay:NO];
    [self.player.moviePlayer prepareToPlay];
    
    return self.player;
}

- (void)play:(YKQualityOptions)quality {
    if (!self.player) [self movieViewController:quality];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}

#pragma mark - Properties

- (NSString *)videoID {
    return [self.contentURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
}

@end
