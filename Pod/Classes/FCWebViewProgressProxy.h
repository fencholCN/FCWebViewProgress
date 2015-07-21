//
//  FCWebViewProgressProxy.h
//  FCPrepare
//
//  Created by fenchol on 15/7/21.
//  Copyright (c) 2015年 fenchol. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FCWebViewProgressBlock)(CGFloat progress);

@interface FCWebViewProgressProxy : NSObject <UIWebViewDelegate>

@property (nonatomic, assign) id <UIWebViewDelegate> webViewDelegate;
@property (nonatomic, readonly, assign) CGFloat progress;
@property (nonatomic, copy) FCWebViewProgressBlock updateBlock;

@end
