//
//  ViewController.m
//  DemoApp
//
//  Created by Yas Kuraishi on 3/8/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "ViewController.h"
#import "YKMediaPlayerKit.h"

#import "YKVimeoVideo.h"
#import "YKYouTubeVideo.h"
#import "YKDirectVideo.h"

NSString *const kYouTubeVideo = @"http://www.youtube.com/watch?v=1hZ98an9wjo";
NSString *const kVimeoVideo = @"http://vimeo.com/42893621";
NSString *const kDirectVideo = @"http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test1_Talkinghead_mp4_480x360.mp4";
NSString *const kOtherVideo = @"http://download.wavetlan.com/SVV/Media/HTTP/BlackBerry.mov";
NSString *const kUnknownVideo = @"http://www.dailymotion.com/video/x21nmr3_exclusive-watch-lego-builders-create-groot_lifestyle";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *youTubeView;
@property (weak, nonatomic) IBOutlet UIImageView *vimeoView;
@property (weak, nonatomic) IBOutlet UIImageView *mp4View;
@property (weak, nonatomic) IBOutlet UIImageView *otherVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *unknownVideoView;

@end

@implementation ViewController {
    YKYouTubeVideo  *_youTubeVideo;
    YKVimeoVideo    *_vimeoVideo;
    YKDirectVideo   *_directVideo;
    YKDirectVideo   *_otherVideo;
    YKUnKnownVideo  *_unknownVideo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _youTubeVideo = [[YKYouTubeVideo alloc] initWithContent:[NSURL URLWithString:kYouTubeVideo]];
    [_youTubeVideo parseWithCompletion:^(NSError *error) {
        [_youTubeVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
            self.youTubeView.image = thumbImage;
        }];
    }];

    _vimeoVideo = [[YKVimeoVideo alloc] initWithContent:[NSURL URLWithString:kVimeoVideo]];
    [_vimeoVideo parseWithCompletion:^(NSError *error) {
        [_vimeoVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
            self.vimeoView.image = thumbImage;
        }];
    }];

    _directVideo = [[YKDirectVideo alloc] initWithContent:[NSURL URLWithString:kDirectVideo]];
    [_directVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
        self.mp4View.image = thumbImage;
    }];
    
    _otherVideo = [[YKDirectVideo alloc] initWithContent:[NSURL URLWithString:kOtherVideo]];
    [_otherVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
        self.otherVideoView.image = thumbImage;
    }];
    
    _unknownVideo = [[YKUnKnownVideo alloc] initWithContent:[NSURL URLWithString:kUnknownVideo]];
    [_unknownVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
        self.otherVideoView.image = thumbImage;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)youTubeButtonPressed:(UIButton *)sender {
    [_youTubeVideo play:YKQualityHigh];
}

- (IBAction)vimeoButtonPressed:(UIButton *)sender {
    [_vimeoVideo play:YKQualityLow];
}

- (IBAction)mp4ButtonPressed:(UIButton *)sender {
    [_directVideo play:YKQualityLow];
}

- (IBAction)otherButtonPressed:(UIButton *)sender {
    [_otherVideo play:YKQualityLow];
}

- (IBAction)unknownButtonPressed:(UIButton *)sender {
    [_unknownVideo play:YKQualityLow];
}

@end

