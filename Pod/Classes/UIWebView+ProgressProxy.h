//
//  UIWebView+ProgressProxy.h
//  FCPrepare
//
//  Created by fenchol on 15/7/21.
//  Copyright (c) 2015年 fenchol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCWebViewProgressProxy.h"

@interface UIWebView (ProgressProxy)

@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, copy) FCWebViewProgressBlock updateBlock;

@property (nonatomic, strong, readonly) FCWebViewProgressProxy *progressProxy;

/**
 * setup progress, if setting delegate, it can be obmited
 */
- (void)setupProgress;

@end
