//
//  YKYouTubeVideo.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 3/13/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKYouTubeVideo.h"
#import "HCYoutubeParser.h"

@interface YKYouTubeVideo()
@property (nonatomic, strong) MPMoviePlayerViewController *player;
@end

@implementation YKYouTubeVideo

#pragma mark - YKVideo Protocol

- (instancetype)initWithContent:(NSURL *)contentURL {
    self = [super init];
    if (self) {
        self.contentURL = contentURL;
    }
    return self;
}

- (void)parseWithCompletion:(void(^)(NSError *error))callback {
    NSAssert(self.contentURL, @"Invalid contentURL");
    
    __weak YKYouTubeVideo *weakSelf = self;
    [HCYoutubeParser h264videosWithYoutubeURL:self.contentURL completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
        YKYouTubeVideo *strongSelf = weakSelf;
        strongSelf.videos = videoDictionary;
        
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        }
    }];
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *thumbImage, NSError *error))callback {
    NSAssert(callback, @"usingBlock cannot be nil");
    
    YouTubeThumbnail youTubeQuality = YouTubeThumbnailDefault;
    switch (quality) {
        case YKQualityLow:
            youTubeQuality = YouTubeThumbnailDefaultMedium;
            break;
        case YKQualityMedium:
            youTubeQuality = YouTubeThumbnailDefaultHighQuality;
            break;
        case YKQualityHigh:
            youTubeQuality = YouTubeThumbnailDefaultMaxQuality;
            break;
    }
    
    [HCYoutubeParser thumbnailForYoutubeURL:self.contentURL thumbnailSize:youTubeQuality completeBlock:^(UIImage *image, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image, nil);
        });
    }];
}

- (NSURL *)videoURL:(YKQualityOptions)quality {
    NSString *strURL = nil;
    
    switch (quality) {
        case YKQualityLow:
            strURL = self.videos[@"medium"];
            break;
        case YKQualityMedium:
            strURL = self.videos[@"small"];
            break;
        case YKQualityHigh:
            strURL = self.videos[@"hd720"];
    }
    
    if (!strURL && self.videos.count > 0) {
        strURL = [self.videos allValues][0]; //defaults to 1st index
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

@end
