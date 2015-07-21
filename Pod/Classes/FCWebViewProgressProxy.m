//
//  FCWebViewProgressProxy.m
//  FCPrepare
//
//  Created by fenchol on 15/7/21.
//  Copyright (c) 2015年 fenchol. All rights reserved.
//

#import "FCWebViewProgressProxy.h"

static NSString *sCompleteURLPath = @"/webViewProgressCompletePath";

static CGFloat sInitialProgressValue = .1f;
static CGFloat sFinalProgressValue = .9f;

@interface FCWebViewProgressProxy ()
{
    NSInteger  _resouceCount;
    NSInteger  _loadedCount;
    NSURL *    _currentURL;
    BOOL       _interactive;
}

@property (nonatomic, readwrite, assign) CGFloat progress;

@end

@implementation FCWebViewProgressProxy


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _reset];
    }
    return self;
}



- (void)setWebViewDelegate:(id)webViewDelegate
{
    if (webViewDelegate != self) {
        _webViewDelegate = webViewDelegate;
    }
}

- (void)_reset
{
    _interactive = NO;
    _resouceCount = 0;
    _loadedCount = 0;
    self.progress = .0f;
}

- (void)_startLoading
{
    if (self.progress < sInitialProgressValue) {
        self.progress = sInitialProgressValue;
    }
}

- (void)_updateProgress
{
    CGFloat progress = self.progress;
    CGFloat newProgress = sFinalProgressValue;
    if (_resouceCount > 0) {
        newProgress = _loadedCount / (CGFloat)_resouceCount;
    }
    
    if (newProgress > sFinalProgressValue) {
        newProgress = sFinalProgressValue;
    }

    if (newProgress < progress) {
        newProgress = progress;
    }
    
    self.progress = newProgress;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (self.updateBlock) {
        self.updateBlock(progress);
    }
}

- (void)_completeLoading
{
    self.progress = 1.f;
}

- (void)_checkCompleteStateForWebView: (UIWebView *)webView
{
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive && !_interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, sCompleteURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self _completeLoading];
    }
}

#pragma mark - webView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.path isEqualToString: sCompleteURLPath]) {
        [self _completeLoading];
        return NO;
    }
    BOOL originShouldStart = YES;
    if ([_webViewDelegate respondsToSelector: @selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        originShouldStart = [_webViewDelegate webView: webView shouldStartLoadWithRequest: request navigationType: navigationType];
    }
    BOOL isTopRequest = [request.mainDocumentURL isEqual: request.URL];
    if (originShouldStart && isTopRequest) {
        _currentURL = request.URL;
        [self _reset];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_webViewDelegate respondsToSelector: @selector(webViewDidStartLoad:)]) {
        [_webViewDelegate webViewDidStartLoad: webView];
    }
    _resouceCount++;
    [self _updateProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([_webViewDelegate respondsToSelector: @selector(webViewDidFinishLoad:)]) {
        [_webViewDelegate webViewDidFinishLoad: webView];
    }
    _loadedCount++;
    [self _updateProgress];
    [self _checkCompleteStateForWebView: webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_webViewDelegate respondsToSelector: @selector(webView:didFailLoadWithError:)]) {
        [_webViewDelegate webView: webView didFailLoadWithError: error];
    }
    _loadedCount++;
    [self _updateProgress];
    [self _checkCompleteStateForWebView: webView];
}

#pragma mark - forwarding

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([_webViewDelegate respondsToSelector: aSelector]) {
        return _webViewDelegate;
    }
    return nil;
}



@end
