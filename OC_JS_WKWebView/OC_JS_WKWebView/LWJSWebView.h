//
//  LWJSWebView.h
//  OC_JS_WKWebView
//
//  Created by liwei on 2018/7/9.
//  Copyright © 2018年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
// ================================================================================================================================================
#pragma mark - js交互网页方法模型
@interface LWJSWebViewSelectorModel : NSObject

/** 方法名 */
@property (nonatomic,copy) NSString * selectorName;
/** 是否需要参数 */
@property (nonatomic,assign) BOOL needPar;

@end
// ================================================================================================================================================
#pragma mark - js交互网页
@interface LWJSWebView : UIView

/** 网页视图 */
@property (nonatomic,strong) WKWebView * wkWebView;

/** 方法数组 */
@property (nonatomic,strong) NSMutableArray<LWJSWebViewSelectorModel *> * funcArray;

- (void)loadRequest:(NSURLRequest *)request;

- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL API_AVAILABLE(macosx(10.11), ios(9.0));

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;


/** 这里要记得添加handlers
    viewWillAppear:
 */
- (void)addScriptMessageHandler;
/**
 addScriptMessageHandler 很容易导致循环引用
 控制器 强引用了WKWebView,WKWebView copy(强引用了）configuration， configuration copy （强引用了）userContentController
 userContentController 强引用了 self （控制器）
 这里要记得移除handlers
 viewWillDisappear:
 */
- (void)removeScriptMessageHandler;

@end
// ================================================================================================================================================
