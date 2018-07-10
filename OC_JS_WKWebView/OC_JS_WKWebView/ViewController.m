//
//  ViewController.m
//  OC_JS_WKWebView
//
//  Created by liwei on 2018/7/9.
//  Copyright © 2018年 liwei. All rights reserved.
//

#import "ViewController.h"
#import "LWJSWebView.h"


@interface ViewController ()

/** 网页视图 */
@property (nonatomic,strong) LWJSWebView * webView;

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView = [[LWJSWebView alloc] initWithFrame:self.view.bounds];
     [self.webView addScriptMessageHandler];
    [self.view addSubview:self.webView];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.webView addScriptMessageHandler];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView removeScriptMessageHandler];
}

@end
