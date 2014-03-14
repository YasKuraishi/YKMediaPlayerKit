//
//  YKDirectVideo.h
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 3/13/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKVideo.h"

@interface YKDirectVideo : NSObject <YKVideo>

/**
 Vimeo video url
 */
@property (nonatomic, strong) NSURL *contentURL;

@end
