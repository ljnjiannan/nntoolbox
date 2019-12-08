//
//  JSFunctions.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/29.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

extension ViewController: SwiftBridgeProtocol{
    
    @objc
    func jsInitDirList(_ arg: Any) {
        self.initDirector()
    }
    
    @objc
    func jsFindDictories(_ arg: Any) {
        self.findDictories(path: arg as! String)
    }
    
    @objc
    func jsLoadFolderDetail(_ arg: Any) {
        self.loadFolderDetail(arg as! String)
    }

    @objc
    func jsRunScript(_ arg: Any) {
        ShellUtil.shared.async(command: arg as! String)
//        ShellUtil.async(command: arg as! String)
//        ShellUtil.shell("source /Users/jiannanliu/.bash_profile")
//        ShellUtil.shell(arg as! String)
//        self.runScript(arg as! String)
    }

    
    @objc
    func loadDirectorList(_ arg: Any) {
        
    }
    
    
    
}
