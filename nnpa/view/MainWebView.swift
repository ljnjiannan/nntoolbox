//
//  MainWebView.swift
//  notionview
//
//  Created by jiannan liu on 2019/12/31.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation
import WebKit

// webview相关操作
extension ViewController:NSWindowDelegate, WKNavigationDelegate, WKUIDelegate {
    
    func initWebView() {
        let config = WKWebViewConfiguration.init()
        let controller = WKUserContentController.init()
        config.userContentController = controller
        var count: UInt32 = 0
        
        let frame = self.view.frame
        self.wkWebView = WKWebView.init(frame: NSRect.init(x: 0, y: 0, width: frame.width, height: frame.height),configuration: config)
        self.view.addSubview(self.wkWebView!)
        self.wkWebView!.load(NSURLRequest(url: NSURL(string:CodeToolsConf.URL_WEBVIEW)! as URL) as URLRequest)
        self.wkWebView!.navigationDelegate = self
        self.wkWebView?.uiDelegate = self
        self.view.window?.delegate = self
        
        let jsBridge = JsBridgeHandler.init(controller: self, wkWebView: self.wkWebView!)
        let methods = class_copyMethodList(JsBridgeHandler.self, &count)
        for i in 0..<count {
            let method = methods![Int(i)]
            if (method_getName(method).description.hasPrefix("js")) {
                let methodName = method_getName(method).description.replacingOccurrences(of: ":", with: "")
                controller.add(jsBridge, name: methodName)
            }
        }
    }
    
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        self.wkWebView!.frame.size = NSSize.init(width: frameSize.width, height: frameSize.height)
        return frameSize
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url{
            print("url:  \(url.absoluteString)  and \(CodeToolsConf.URL_WEBVIEW)")
            if (url.absoluteString == "about:blank") {}
            else if (!url.absoluteString.starts(with: CodeToolsConf.URL_WEBVIEW)) {
                NSWorkspace.shared.open(url)
                return
            } else if (navigationAction.targetFrame == nil) {
                webView.load(navigationAction.request)
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func loadJsFunction(_ functionName:String, content:String) {
        self.wkWebView!.execJavaScript(funcName: functionName, content:content)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    
    
}
