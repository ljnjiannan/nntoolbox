//
//  JSFunctions.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/29.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation
import SwiftyJSON
import WebKit

class JsBridgeHandler:NSObject,WKScriptMessageHandler {
    
    var userDefaultBridge:UserDefaultsBridgeProtocol?
    var fileBridge: FileBridgeProtocol?
    var wkWebView: WKWebView?
    var controller: ViewController?
    var lock = NSLock()

    init(controller: ViewController,wkWebView: WKWebView) {
        super.init()
        self.wkWebView = wkWebView
        self.controller = controller
        self.initBridge()
    }
    
    func initBridge() {
        self.userDefaultBridge = UserDefaultsBridge()
        self.fileBridge = FileBridge()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let sel = Selector("\(message.name):")
        if (self.responds(to: sel)) {
            self.perform(sel,with: message.body)
        }
    }
    
    @objc
    func jsBridge(_ arg: Any) {
        let json = arg as! Dictionary<String, Any>
        let functionName = json["name"] as! String
        let body = json["body"] as! Dictionary<String, Any>
        self.execFunctions(functionName, body: body)
    }
    
    func execFunctions(_ functionName:String,body:Dictionary<String, Any>) {
        print(functionName)
        var result:Any?
        var path = ""
        if body["path"] != nil  {
            path = body["path"] as! String
        }
        switch functionName {
            //初始化文件目录
        case "initDirectory":
            result = self.controller?.initDirectory()
            break
        case "getSettingData":
            let rootPath = UserDefaults.standard.string(forKey: CodeToolsConf.USER_DEFAULT_ROOT_DIRECTORY)
            let idePath = UserDefaults.standard.string(forKey: CodeToolsConf.USER_DEFAULT_IDE_PATH)
            let terminalPath = UserDefaults.standard.string(forKey: CodeToolsConf.USER_DEFAULT_TERMINAL_PATH)
            result = ["rootPath": rootPath,"idePath": idePath, "terminalPath": terminalPath].toJSONString()
            break
        case "chooseDirectory":
            let type = body["type"] as! String
            let _ = self.controller?.chooseDir(type: type)
            break
        // 获取UserDDefault信息
        case "getUserDefaultsDictionary":
            let key = body["key"] as! String
            result = (userDefaultBridge?.getUserDefaultsDictionary(key: key))!
            break
        case "getUserDefaultsArray":
            let key = body["key"] as! String
            result = (userDefaultBridge?.getUserDefaultsArray(key: key))!
            break
        case "setUserDefaultsArray":
            let key = body["key"] as! String
            let value = body["value"]
            result = (userDefaultBridge?.setUserDefaultsArray(key: key, value: value as Any))!
            break
        case "removeUserDefaultsArray":
            let key = body["key"] as! String
            let value = body["index"] as! Int
            result = (userDefaultBridge?.removeUserDefaultsArray(key: key, index: value))!
            break
        // 获取文件夹信息
        case "getDirectorys":
            result = fileBridge?.getDirectorys(path: path)
            break
        // 获取文件夹明细
        case "getDirectoryDetail":
            result = fileBridge?.getDirectoryDetail(path: path).reflectToDict()
            break
        // 获取nodejs 信息
        case "getNodejsInfo":
            result = FileManager.nodejsInfo(path).toJSONString()
            break
        // 获取git 信息
        case "getGitInfo":
            let info = GitUtil.getBranchs(path)
            let status = GitUtil.getStatusInfo(path)
            let statusList = GitUtil.getStatusInfoList(path)
            result = ["info": info,"status": status,"statusList": statusList]
            break
        // 执行git命令
        case "runGitScript":
            let script = body["script"] as! String
            let _ = ShellUtil.shared.sync(command: "cd \(path) && \(script)")
            break
        // 执行nodejs命令
        case "runNodejsScript":
            let script = body["script"] as! String
            let command = body["command"] as! String
            ShellUtil.shared.async(script: script, name: path,command: command, output: {
                output in
                self.updateScriptInfo()
                self.wkWebView!.execJavaScript(funcName: "swiftBindingBridge", content:["name":"updateLog","result":ShellUtil.shared.taskList.getLogs()].toJSONString()!)
            }, terminate: {
                terminate in
                self.updateScriptInfo()
            })
            result = FileManager.nodejsInfo(path).toJSONString()
            break
        case "terminateScript":
            let command = body["command"] as! String
            ShellUtil.shared.terminateTask(id: TaskUtil.getTaskId(tag: path, command: command))
            result = FileManager.nodejsInfo(path).toJSONString()

            break
        case "getRunningList":
            result = ShellUtil.shared.taskList.getListJson()
            break
        case "getProjectsInfo":
            break
        case "openUrl":
            NSWorkspace.shared.open(URL.init(string: path)!)
            break
        case "openFile":
            if let app = body["app"]{
                NSWorkspace.shared.openFile(path, withApplication: app as? String)
            } else {
                NSWorkspace.shared.openFile(path)
            }
            break
        case "terminalAllTask":
            ShellUtil.shared.taskList.removeAllTask()
            if (self.controller != nil) {
                controller?.closeApplication()
            }
            break
        case "showSettingView":
            self.wkWebView?.evaluateJavaScript("showSettingView()", completionHandler: nil)
            break
        default:
            print("default")
        }
        self.wkWebView!.execJavaScript(funcName: "swiftBridge", content:["name":functionName,"result":result].toJSONString()!)
    }
    
    func updateScriptInfo() {
        self.controller!.addStatusBar(tastList: ShellUtil.shared.taskList)
    }
    
    func loadJsFunction(_ functionName:String, content:String) {
        self.wkWebView!.execJavaScript(funcName: functionName, content:content)
    }
}

extension ViewController: SwiftBridgeProtocol{

    func initRunngingList() {
        let (status, result) = ShellUtil.shared.sync(command: "ps -ax")
        if (status == 0) {
            let ts = result.split(separator: "\n").map{$0.trimmingCharacters(in: .whitespaces)}
            var pidList = [String]()
            for row in ts {
                let item = row.split(separator: " ").map{$0.trimmingCharacters(in: .whitespaces)}
                pidList.append(item[0])
            }
            let historyList = UserDefaultsBridge().getUserDefaultsDictionary(key: CodeToolsConf.USER_DEFAULT_HISTORY)
            for history in historyList {
                let value = history.value as! [String:Any]
                if let pid = value["pid"] as? Int {
                    if (pidList.contains(String(pid))) {
                        let tag = value["tag"] as! String
                        let command = value["command"] as! String
                        let _ = ShellUtil.shared.taskList.addTask(tag: tag, task: nil, command: command,pid: String(pid))
                    }
                }
            }
        }
    }

    
    /**
     初始化目录结构
     */
    @objc
    func jsInitDirList(_ arg: Any) {
//        self.initDirectory()
//        self.updateScriptInfo()
    }
    
    /**
     获取目录列表
     */
    @objc
    func jsFindDictories(_ arg: Any) {
        self.findDictories(path: arg as! String)
    }
    
    @objc
    func jsLoadFolderDetail(_ arg: Any) {
        self.loadFolderDetail(arg as! String)
    }

    /**
     执行脚本命令
     */
    @objc
    func jsRunScript(_ arg: Any) {
//        let json = arg as! Dictionary<String, Any>
//        ShellUtil.shared.async(command: json["script"]! as! String, name: json["name"]! as! String,output: {
//            output in
//            self.updateScriptInfo()
//        }, terminate: {
//            terminate in
//            self.updateScriptInfo()
//        })
//        self.loadFolderDetail(json["name"]! as! String)
    }

    /**
     结束脚本命令
     */
    @objc
    func jsTerminateScript(_ arg: Any) {
//        ShellUtil.shared.terminateTask(tag: arg as! String)
        self.loadFolderDetail(arg as! String)
    }
    
    /**
    获取git信息
     */
    @objc
    func jsGitInfo(_ arg: Any) {
        let info = GitUtil.getBranchs(arg as! String)
        let status = GitUtil.getStatusInfo(arg as! String)
        let result = ["info": info,"status": status]
        self.loadJsFunction("swiftLoadGitInfo", content: result.toJSONString()!)
    }
    
    /**
     设置远程跟踪分支
     */
    @objc
    func jsGitSetFollow(_ arg: Any) {
        let json = arg as! Dictionary<String, Any>

        GitUtil.followBranch(json["path"] as! String,remote: json["remote"] as! String, current: json["current"] as! String)
        self.jsGitInfo(json["path"] as Any)
    }

    /**
     设置远程跟踪分支
     */
    @objc
    func jsGitAddAll(_ arg: Any) {
        let json = arg as! Dictionary<String, Any>
        GitUtil.addAll(json["path"] as! String)
        self.jsGitInfo(json["path"] as Any)
    }
    
    /**
     git提交
     */
    @objc
    func jsGitCommit(_ arg: Any) {
        let json = arg as! Dictionary<String, Any>
        GitUtil.commit(json["path"] as! String,json["message"] as! String)
        self.jsGitInfo(json["path"] as Any)
    }
    
    /**
     git推送
     */
    @objc
    func jsGitPush(_ arg: Any) {
        let json = arg as! Dictionary<String, Any>
        GitUtil.push(json["path"] as! String,json["remote"] as! String)
        self.jsGitInfo(json["path"] as Any)
    }
    
    
    func updateScriptInfo() {
        self.addStatusBar(tastList: ShellUtil.shared.taskList)
        self.loadJsFunction("swiftUpdateScriptInfo", content: ShellUtil.shared.taskList.tuJsonString())
    }
    
}
