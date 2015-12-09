//
//  VimeoVideo.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 3/13/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKVimeoVideo.h"
#import <IGVimeoExtractor/IGVimeoExtractor.h>

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
    
    
    [IGVimeoExtractor fetchVideoURLFromURL:[self.contentURL absoluteString] completionHandler:^(NSArray<IGVimeoVideo *> * _Nullable videos, NSError * _Nullable error) {

        if (callback_if_error(error)) return;

        self.videos = [[self class] videosDictionary:videos];
        self.thumbs = [[self class] thumbsDictionary:videos];
        
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }        
    }];

}

+ (NSDictionary*) videosDictionary:(NSArray<IGVimeoVideo*>*) videos {

    NSMutableDictionary<NSNumber*,NSURL*> * dict = [NSMutableDictionary dictionaryWithCapacity:videos.count];
    
    for(IGVimeoVideo* video in videos) {
        
        dict[@(video.quality)] = video.videoURL;
    }
    
    return dict;
    
}

+ (NSDictionary*) thumbsDictionary:(NSArray<IGVimeoVideo*>*) videos {
    
    NSMutableDictionary<NSNumber*,NSURL*> * dict = [NSMutableDictionary dictionaryWithCapacity:videos.count];
    
    for(IGVimeoVideo* video in videos) {
        
        dict[@(video.quality)] = video.thumbnailURL;
    }
    
    return dict;
    
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
    NSURL *url = nil;
    
    switch (quality) {
        case YKQualityLow:
            url = self.videos[@(IGVimeoVideoQualityLow)];
            break;
        case YKQualityMedium:
            url = self.videos[@(IGVimeoVideoQualityMedium)];
            break;
        case YKQualityHigh:
            url = self.videos[@(IGVimeoVideoQualityHigh)]?: self.videos[@(IGVimeoVideoQualityBest)];
    }
    
    if (!url && self.videos.count > 0) {
        url = [self.videos allValues][0]; //defaults to 1st index
    }
    
    return url;
}

- (NSURL *)thumbURL:(YKQualityOptions)quality {
    NSURL *url = nil;
    switch (quality) {
        case YKQualityLow:
            url = self.thumbs[@(IGVimeoVideoQualityLow)];
            break;
        case YKQualityMedium:
            url = self.thumbs[@(IGVimeoVideoQualityMedium)];
            break;
        case YKQualityHigh:
            url = self.thumbs[@(IGVimeoVideoQualityHigh)];
        default:
            url = self.thumbs[@(IGVimeoVideoQualityBest)];
    }
    
    if (!url && self.thumbs.count > 0) {
        url = [self.thumbs allValues][0]; //defaults to 1st index
    }

    return url;
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
