//
//  YKDirectVideo.h
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 7/20/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKVideo.h"

@interface YKUnKnownVideo : NSObject <YKVideo>

/**
 UnKnown video url
 */
@property (nonatomic, strong) NSURL *contentURL;

@end
