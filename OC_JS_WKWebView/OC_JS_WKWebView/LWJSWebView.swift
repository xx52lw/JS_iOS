//
//  LWJSWebView.swift
//  swift_JS_WKWebView
//
//  Created by liwei on 2018/7/10.
//  Copyright © 2018年 liwei. All rights reserved.
//

import UIKit
import WebKit
// ================================================================================================================================
// MARK: - js交互网页
class LWJSWebView: UIView {

    /// 方法数组
    var funcArray = [LWJSWebViewSelectorModel]()
    /// 网页视图
    lazy var wkWebView: WKWebView = {
        let conf = WKWebViewConfiguration.init()
        let pref = WKPreferences.init()
        pref.javaScriptCanOpenWindowsAutomatically = true
        conf.preferences = pref
        let webView = WKWebView.init(frame: CGRect.zero, configuration: conf)
        webView.uiDelegate = self
        return webView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let path = Bundle.main.path(forResource: "JSSelector", ofType: ".plist")
        let arrayDict = NSArray.init(contentsOfFile: path!)
        let count : Int = (arrayDict?.count)!
        for index in 0..<count {
            let dict = arrayDict![index] as! NSDictionary
            let model = LWJSWebViewSelectorModel.init()
            model.selectorName = dict["selectorName"] as! String
            model.needPar = dict["needPar"] as! Bool
            funcArray.append(model)
        }
        self.addSubview(self.wkWebView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.wkWebView.frame = self.bounds
    }
    
    ///  添加handlers
    func addScriptMessageHandler() {
        removeScriptMessageHandler()
        for (_,value) in self.funcArray.enumerated() {
            self.wkWebView.configuration.userContentController.add(self, name: value.selectorName)
        }
    }
    ///   addScriptMessageHandler 很容易导致循环引用控制器 强引用了WKWebView,WKWebView copy(强引用了）configuration， configuration copy （强引用了）userContentControlleruserContentController 强引用了 self （控制器）这里要记得移除handlersviewWillDisappear:
    func removeScriptMessageHandler() {
        for (_,value) in self.funcArray.enumerated() {
            self.wkWebView.configuration.userContentController.removeScriptMessageHandler(forName: value.selectorName)
        }
    }
    
    
    
    @objc  func OCtoJS() {
        print("OCtoJS")
    }
    
    
    
}
// ================================================================================================================================
// MARK: - js交互网页代理
extension LWJSWebView : WKUIDelegate,WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("body:\(message.body)")
        var model : LWJSWebViewSelectorModel? = nil
        for (_,value) in self.funcArray.enumerated() {
            if value.selectorName == message.name {
                model = value
                break
            }
        }
        if model == nil {
            return
        }
        var selector = Selector.init((model?.selectorName)!)
        if ((model?.needPar = true) != nil) {
            selector = Selector.init(String(describing: (model?.selectorName)! + ":"))
        }
        if responds(to: selector) {
            if ((model?.needPar = true) != nil) {
                perform(selector, with: message.body)
            }
            else {
                perform(selector)
            }
        }
    }
}
// ================================================================================================================================
// MARK: - js交互网页模型
class LWJSWebViewSelectorModel : NSObject {
    
    /// 方法名
    var selectorName = ""
    /// 是否需要参数
    var needPar = false
    
    override init() {
        
    }
    
}
// ================================================================================================================================
