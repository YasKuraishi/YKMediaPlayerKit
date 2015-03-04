//
//  YKMediaHelper.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 3/8/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKMediaPlayerKit.h"

//TODO: Implement NSURLCredential for secure URL access

//"assets-library://asset/asset.MOV?id=1000000394&ext=MOV"
//Supported Formats - https://developer.apple.com/library/ios/documentation/MediaPlayer/Reference/MPMoviePlayerController_Class/Reference/Reference.html


#if !__has_feature(objc_arc)
    #error YKMediaHelper needs ARC
#endif

#define NSErrorFromString(cd, msg) [NSError errorWithDomain:@"YKMediaPlayerKit" code:cd userInfo:@{@"NSLocalizedRecoverySuggestion": msg}]

NSString *const kSupportedVideos = @".mov, .mp4, .mpv, .3gp";
NSString *const kVideoNotSupported = @"Video not supported";

@interface YKMediaPlayerKit()
@property (nonatomic, strong) MPMoviePlayerViewController *player;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) id<YKVideo> video;
@property (nonatomic) YKVideoTypeOptions videoType;
@end

@implementation YKMediaPlayerKit

#pragma mark - Public Methods

- (instancetype)initWithURL:(NSURL *)contentURL {
    self = [super init];
    if (self) {
        self.contentURL = contentURL;
    }
    return self;
}

- (void)parseWithCompletion:(void(^)(YKVideoTypeOptions, id<YKVideo>, NSError *))callback {
    switch (self.videoType) {
        case YKVideoTypeYouTube:
            self.video = [[YKYouTubeVideo alloc] initWithContent:self.contentURL];
            break;
        case YKVideoTypeVimeo:
            self.video = [[YKVimeoVideo alloc] initWithContent:self.contentURL];
            break;
        case YKVideoTypeDirect:
            self.video = [[YKDirectVideo alloc] initWithContent:self.contentURL];
            
            if (callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(self.videoType, self.video, nil);
                });
            }
            return;
        case YKVideoTypeUnknown:
            self.video = [[YKUnKnownVideo alloc] initWithContent:self.contentURL];
            
            if (callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(self.videoType, self.video, nil);
                });
            }
            return;
    }
    
    [self.video parseWithCompletion:^(NSError *error) {
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(self.videoType, self.video, error);
            });
        }
    }];
}

- (void)playWithCompletion:(void(^)(YKVideoTypeOptions, id<YKVideo>, NSError *))callback {
    [self parseWithCompletion:^(YKVideoTypeOptions videoType, id<YKVideo> video, NSError *error) {
        [self.video play:self.videoQuality];
    }];
}

- (void)thumbWithCompletion:(void(^)(UIImage *thumb, NSError *error))callback {
    [self parseWithCompletion:^(YKVideoTypeOptions videoType, id<YKVideo> video, NSError *error) {
        [self.video thumbImage:self.thumbQuality completion:^(UIImage *thumbImage, NSError *error) {
            if (callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(thumbImage, error);
                });
            }
        }];
    }];
}

#pragma mark - Private Methods

- (MPMoviePlayerViewController *)movieViewController:(YKQualityOptions)quality {
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:self.contentURL];
    [self.player.moviePlayer setShouldAutoplay:NO];
    [self.player.moviePlayer prepareToPlay];
    
    return self.player;
}

- (void)play:(YKQualityOptions)quality {
    if (!self.player) [self movieViewController:quality];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}

#pragma mark - Class Methods

+ (void)parse:(NSURL *)contentURL completion:(void(^)(YKVideoTypeOptions, id<YKVideo>, NSError *))callback {
    YKMediaPlayerKit *playerKit = [[YKMediaPlayerKit alloc] initWithURL:contentURL];
    
    [playerKit parseWithCompletion:^(YKVideoTypeOptions videoType, id<YKVideo> video, NSError *error) {
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(videoType, video, error);
            });
        }
    }];
}

+ (void)play:(NSURL *)contentURL quality:(YKQualityOptions)quality completion:(void(^)(YKVideoTypeOptions, id<YKVideo>, NSError *))callback {
    YKMediaPlayerKit *playerKit = [[YKMediaPlayerKit alloc] initWithURL:contentURL];
    playerKit.videoQuality = quality;
    
    [playerKit playWithCompletion:^(YKVideoTypeOptions videoType, id<YKVideo> video, NSError *error) {
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(videoType, video, error);
            });
        }
    }];
}

+ (void)thumb:(NSURL *)contentURL quality:(YKQualityOptions)quality completion:(void(^)(UIImage *thumb, NSError *))callback {
    YKMediaPlayerKit *playerKit = [[YKMediaPlayerKit alloc] initWithURL:contentURL];
    playerKit.thumbQuality = quality;
    
    [playerKit thumbWithCompletion:^(UIImage *thumb, NSError *error) {
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(thumb, error);
            });
        }
    }];
}

#pragma mark - Properties

- (YKVideoTypeOptions)videoType {
    NSString *strURL = self.contentURL.absoluteString;
    NSRange range = [kSupportedVideos rangeOfString:self.contentURL.pathExtension];
    
    if (range.location != NSNotFound) {
        return YKVideoTypeDirect;
    } else if ([strURL hasPrefix:@"assets-library://"] && [strURL hasSuffix:@"&ext=MOV"]) {
        return YKVideoTypeDirect;
    } else if ([self.contentURL.host.lowercaseString hasSuffix:@"youtube.com"] || [self.contentURL.host.lowercaseString hasSuffix:@"youtu.be"]) {
        return YKVideoTypeYouTube;
    } else if ([self.contentURL.host.lowercaseString hasSuffix:@"vimeo.com"]) {
        return YKVideoTypeVimeo;
    } else {
        return YKVideoTypeUnknown;
    }
}

- (UIViewController *)rootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
