//
//  UIWebView+ProgressProxy.m
//  FCPrepare
//
//  Created by fenchol on 15/7/21.
//  Copyright (c) 2015年 fenchol. All rights reserved.
//

#import "UIWebView+ProgressProxy.h"
#import <objc/runtime.h>

const void *gProxyKey = &gProxyKey;
const void *gProgressKey = &gProgressKey;
const void *gUpdateProgressKey = &gUpdateProgressKey;

@implementation UIWebView (ProgressProxy)

@dynamic progress;
@dynamic updateBlock;

+ (void)load
{
    Method originalMethod = class_getInstanceMethod([UIWebView class], @selector(setDelegate:));
    Method swapMethod = class_getInstanceMethod([UIWebView class], @selector(setHookDelegate:));
    method_exchangeImplementations(originalMethod, swapMethod);
}



- (void)setHookDelegate: (id)delegate
{
    self.progressProxy.webViewDelegate = delegate;
    
    [self setHookDelegate: self.progressProxy];
}

- (id)getHookDelegate
{
    return self.progressProxy.webViewDelegate;
}


- (CGFloat)progress
{
    return self.progressProxy.progress;
}


- (FCWebViewProgressProxy *)progressProxy
{
    FCWebViewProgressProxy *proxy = objc_getAssociatedObject(self,  gProxyKey);
    if (proxy == nil) {
        proxy = [[FCWebViewProgressProxy alloc] init];
        [self setHookDelegate: proxy];
        proxy.updateBlock = ^(CGFloat progress){
          __weak typeof(&*self) safeSelf = self;
            [safeSelf willChangeValueForKey: @"progress"];
            [safeSelf didChangeValueForKey: @"progress"];
            if (safeSelf.updateBlock) {
                safeSelf.updateBlock(progress);
            }
        };
        objc_setAssociatedObject(self, gProxyKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}

- (void)setUpdateBlock:(FCWebViewProgressBlock)updateBlock
{
    objc_setAssociatedObject(self, gUpdateProgressKey, updateBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (FCWebViewProgressBlock)updateBlock
{
    return objc_getAssociatedObject(self, gUpdateProgressKey);
}

- (void)setupProgress
{
    [self progressProxy];
}

@end
