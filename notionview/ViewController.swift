//
//  ViewController.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/27.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Cocoa
import WebKit
import Alamofire

class ViewController: NSViewController,ShellScriptDelegate{
    var wkWebView: WKWebView? = nil
    var scriptFiled: NSTextField?
    let url = "http://192.168.2.177:8080"
    var fileList : [String]?
//    let url = "http://baidu.com"
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        self.initWebView()
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.title = "code-tools"
        self.view.window?.titleVisibility = .hidden
    }
    
    func scriptCall(_ callback: String) {
        self.scriptFiled?.stringValue = self.scriptFiled!.stringValue + callback
    }
    

}
// webview相关操作
extension ViewController:NSWindowDelegate, WKNavigationDelegate, WKUIDelegate,WKScriptMessageHandler {
    
    func initWebView() {
        let config = WKWebViewConfiguration.init()
        let controller = WKUserContentController.init()
        config.userContentController = controller
//        controller.add(self, name: "jsTest")
//        controller.add(self, name: "initDirList")

        var count: UInt32 = 0
        let methods = class_copyMethodList(ViewController.self, &count)
        for i in 0..<count {
            let method = methods![Int(i)]
            if (method_getName(method).description.hasPrefix("js")) {
                let methodName = method_getName(method).description.replacingOccurrences(of: ":", with: "")
                controller.add(self, name: methodName)
            }
        }
        
        let frame = self.view.frame
        
        self.scriptFiled = NSTextField.init(frame: NSRect.init(x: 0, y: 0, width: frame.width, height: 200))
        self.scriptFiled?.isEnabled = false
        self.view.addSubview(self.scriptFiled!)
        
        self.wkWebView = WKWebView.init(frame: NSRect.init(x: 0, y: 200, width: frame.width, height: frame.height - 200),configuration: config)
        self.view.addSubview(self.wkWebView!)
        self.wkWebView!.load(NSURLRequest(url: NSURL(string:self.url)! as URL) as URLRequest)
        self.wkWebView!.navigationDelegate = self
        self.wkWebView?.uiDelegate = self
        self.view.window?.delegate = self
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        let sel = Selector(("\(message.name):"))
        if (self.responds(to: sel)) {
            self.perform(sel,with: message.body)
        }
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        self.wkWebView!.frame.size = NSSize.init(width: frameSize.width, height: frameSize.height - 200)
        return frameSize
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func loadJsFunction(_ functionName:String, content:String) {
        self.wkWebView!.execJavaScript(funcName: functionName, content:content)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
        print(message)
    }
    
    
    
}

// 选择目录相关操作
extension ViewController {
    
    // 初始化目录选择
    func initDirector() {
//        ShellUtil.sync(command: "node -v")
//        ShellUtil.sync(command: "cd /Users/jiannanliu/Project/github/electron-quick-start")
//        ShellUtil.async(command: "node")
//        ShellUtil.init().shell("node -v\n")
        var recentlyUrl = UserDefaults.standard.string(forKey: "recentlyUrl")
        recentlyUrl = "/Users/jiannanliu/Projects"
//        self.chooseDir()
//        self.saveBookmarkData(url: URL.init(string: "/Users/jiannanliu")!)
        if ((recentlyUrl) != nil) {
//            let data = UserDefaults.standard.data(forKey: recentlyUrl!)
//            self.getBookmarkAuthor(data!)
            self.findDictories(path: recentlyUrl!)
        } else {
            self.chooseDir()
        }
    }
    
    // 选择目录
    func chooseDir() {
        let dialog = NSOpenPanel()
        dialog.canChooseDirectories = true
        dialog.begin(completionHandler: {
            response in
            for url in dialog.urls {
//                self.saveBookmarkData(url: url)
                self.findDictories(path: url.path)
            }
        })
    }
    
    // 存储bookmark
    func saveBookmarkData(url:URL) {
        do{
            let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data as Any, forKey: url.path)
            UserDefaults.standard.set(url.path, forKey: "recentlyUrl")
            self.getBookmarkAuthor(data)
//            self.findDictories(path: url.path)
        }catch let err as NSError {
            print(err)
        }
    }
    
    // 获取目录授权
    func getBookmarkAuthor(_ data:Data) {
        do{
            var isStale:Bool = true
            let allowUrl = try URL.init(resolvingBookmarkData: data, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            let _ = allowUrl.startAccessingSecurityScopedResource()
        } catch {}
    }
    
    // 获取目录列表
    func findDictories(path:String) {
        do {
            let dir = try FileManager.default.contentsOfDirectory(atPath: path).filter{
                item in
                let filterList = [".DS_Store", ".git", ".gitignore"]
                return !filterList.contains(item)
            }
            
            var fileList = [String]()
            for filename in dir {
                var model = DirectorListModel()
                model.name = filename
                model.path = "\(path)/\(filename)"
                model.isFolder = FileManager.isDirector(path: model.path!)
                model.git = FileManager.isGitDirector(model.path!)
                model.folderType = FileManager.directorType(model.path!)
                fileList.append(try model.toJSONString())
            }
            self.fileList = fileList
            let dic = [
                "list": fileList.toJSONString()!,
                "path": path
            ]
//            print(dic.toJSONString())
            self.loadJsFunction("swiftLoadDirectorList", content: dic.toJSONString()!)
        }catch let err as NSError {
            print(err)
        }
    }
    
    // 获取文件夹详情
    func loadFolderDetail(_ path: String) {
        let model = FileManager.folderDetail(path)
        do {
            try self.loadJsFunction("swiftLoadFolderDetail", content: model.toJSONString())
        }catch {}
    }
}
