//
//  YKDirectVideo.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 7/20/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKUnKnownVideo.h"

#define kNavBarHeight (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) ? 44.0f : 64.0f)

//CGFloat const kNavBarHeight = 64.0f;

@interface YKUnKnownVideo()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation YKUnKnownVideo

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
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *thumbImage, NSError *error))callback {
    NSAssert(callback, @"completion block cannot be nil");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) callback([UIImage imageNamed:@"UnKnownVideo.jpg"], nil);
    });
}

- (NSURL *)videoURL:(YKQualityOptions)quality {
    return self.contentURL;
}

#pragma warning Move to Parent class

- (MPMoviePlayerViewController *)movieViewController:(YKQualityOptions)quality {
    return nil;
}

- (void)play:(YKQualityOptions)quality {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGSize viewSize = rootViewController.view.frame.size;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, viewSize.width, viewSize.height-kNavBarHeight)];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.contentURL]];
    
    self.viewController = [UIViewController new];
    self.viewController.view = self.webView;
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                  target:self
                                  action:@selector(dismiss)];;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, kNavBarHeight)];
    navBar.items = @[navItem];
    
    [self.webView addSubview:navBar];
    
    [rootViewController presentViewController:self.viewController animated:YES completion:nil];
}

- (void)dismiss {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
