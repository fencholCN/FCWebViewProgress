//
//  FCViewController.m
//  FCWebViewProgress
//
//  Created by fenchol on 07/21/2015.
//  Copyright (c) 2015 fenchol. All rights reserved.
//

#import "FCViewController.h"
#import <FCWebViewProgress/FCWebViewProgressProxy.h>
//#import "UIWebView+ProgressProxy.h"

@interface FCViewController ()

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) FCWebViewProgressProxy *webViewProxy;

@end

@implementation FCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"example";
    
    self.progressView = [[UIView alloc] init];
    [self.view addSubview: self.progressView];
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview: self.webView];
    self.webView.delegate = self;
    self.progressView.frame = CGRectMake(0, 64, 0, 5);
    self.progressView.backgroundColor = [UIColor blueColor];
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.webView.frame = CGRectMake(0, 69, bounds.size.width, bounds.size.height-69);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(reloadWebView)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target: self action: @selector(loadUrl)];
#ifdef UseCategory
    //please remove code of UIWebView+ProgressProxy
    [self.webView addObserver: self forKeyPath: @"progress" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context: nil];
#else
    self.webViewProxy = [[FCWebViewProgressProxy alloc]init];
    self.webView.delegate = self.webViewProxy;
    [self.webViewProxy addObserver: self forKeyPath: @"progress" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context: nil];
#endif
}

- (void)loadUrl
{
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://www.163.com"]]];
}

- (void)reloadWebView
{
    NSLog(@"%@", self.webView.delegate);
    [self.webView reload];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString: @"progress"]) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        [UIView beginAnimations: nil context: nil];
#ifdef UseCategory
        self.progressView.frame = CGRectMake(0, 64, bounds.size.width * self.webView.progress,  5);
#else
        //please remove code of UIWebView+ProgressProxy
        self.progressView.frame = CGRectMake(0, 64, bounds.size.width * self.webViewProxy.progress,  5);
#endif
        [UIView commitAnimations];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
