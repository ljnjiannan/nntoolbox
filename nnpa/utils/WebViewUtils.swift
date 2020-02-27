//
//  WebViewUtils.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/28.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

import WebKit

extension WKWebView {
    
    func execJavaScript(funcName:String,content:String) {
        let str = "\(funcName)(\(content))"
        self.evaluateJavaScript(str, completionHandler: {
            (result, err) in
            if (err != nil) {
                print(err as Any)
                return
            }
            if ((result) != nil) {
                return
            }

        })

    }
    
}
