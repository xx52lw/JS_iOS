//
//  LWJSWebView.m
//  OC_JS_WKWebView
//
//  Created by liwei on 2018/7/9.
//  Copyright © 2018年 liwei. All rights reserved.
//

#import "LWJSWebView.h"

// ================================================================================================================================================
#pragma mark - js交互网页
@interface LWJSWebView()<WKUIDelegate,WKScriptMessageHandler>

@end
// ================================================================================================================================================
#pragma mark - js交互网页
@implementation LWJSWebView

#pragma mark - 懒加载网页视图
- (WKWebView *)wkWebView {
    if (_wkWebView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        configuration.preferences = preferences;
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
//        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _wkWebView.UIDelegate = self;
    }
    return _wkWebView;
}

#pragma mark - 懒加载方法数组
- (NSMutableArray<LWJSWebViewSelectorModel *> *)funcArray {
    if (_funcArray == nil) {
        _funcArray = [NSMutableArray array];
       NSString *path = [[NSBundle mainBundle] pathForResource:@"JSSelector" ofType:@".plist"];
        NSArray *arrayDict = [NSMutableArray arrayWithContentsOfFile:path];
        for (NSDictionary *dict in arrayDict) {
            LWJSWebViewSelectorModel *model = [[LWJSWebViewSelectorModel alloc] init];
            model.selectorName = dict[@"selectorName"];
            model.needPar = dict[@"needPar"];
            [_funcArray addObject:model];
        }
    }
    return _funcArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.wkWebView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.wkWebView.frame = self.bounds;
}

- (void)loadRequest:(NSURLRequest *)request {
    [self.wkWebView loadRequest:request];
}
- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL  {
    [self.wkWebView loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL {
    [self.wkWebView loadHTMLString:string baseURL:baseURL];
}

#pragma mark 添加handlers
- (void)addScriptMessageHandler {
    [self removeScriptMessageHandler];
    [self.funcArray enumerateObjectsUsingBlock:^(LWJSWebViewSelectorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.wkWebView.configuration.userContentController addScriptMessageHandler:self name:obj.selectorName];
    }];
}
#pragma mark 移除handlers
- (void)removeScriptMessageHandler {
    [self.funcArray enumerateObjectsUsingBlock:^(LWJSWebViewSelectorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:obj.selectorName];
    }];
}
#pragma mark  WKScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    //    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
       NSLog(@"body:%@",message.body);
        LWJSWebViewSelectorModel *selectorModel = nil;
        for (LWJSWebViewSelectorModel *model in self.funcArray) {
            if ([model.selectorName isEqualToString:message.name]) {
                selectorModel = model;
                break;
            }
        }
    if (selectorModel == nil) {
        return;
    }
    SEL selector = NSSelectorFromString(selectorModel.selectorName);
    if (selectorModel.needPar == YES) {
        selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",selectorModel.selectorName]);
    }
    if ([self respondsToSelector:selector]) {
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (selectorModel.needPar == YES) {
            [self performSelector:selector withObject:message.body];
        }
        else {
            [self performSelector:selector];
        }
# pragma clang diagnostic pop
    }
}
#pragma mark - 调用方法
- (void)OCtoJS:(id)par {
    
}
- (void)JStoOC:(id)par {
    // 将结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"JStoOCResult('%@')",@"回调成功"];
    [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}
@end
// ================================================================================================================================================
#pragma mark - js交互网页方法模型
@implementation LWJSWebViewSelectorModel

@end
// ================================================================================================================================================
