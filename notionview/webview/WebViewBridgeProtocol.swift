//
//  WebViewBridgeProtocol.swift
//  notionview
//
//  Created by jiannan liu on 2019/12/2.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

// js调用swift原生方法
protocol JSBridgeProtocol {
    
}

// swift调用js方法
protocol SwiftBridgeProtocol {
    func jsInitDirList(_ arg:Any)
    
    func jsFindDictories(_ arg:Any)
}


