//
//  JSFunctions.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/29.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation
import SwiftyJSON

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
        print(arg)
        let json = arg as! Dictionary<String, Any>
        ShellUtil.shared.async(command: json["script"]! as! String, name: json["name"]! as! String,output: {
            output in
            self.scriptCall(output)
        }, terminate: {
            terminate in
            print(terminate)
        })
    }

    @objc
    func jsTerminateScript(_ arg: Any) {
        ShellUtil.shared.terminateTask(tag: arg as! String)
    }
    
    @objc
    func loadDirectorList(_ arg: Any) {
        
    }
    
    
    
}
