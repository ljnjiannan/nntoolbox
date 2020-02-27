//
//  ViewController.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/27.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Cocoa
import Alamofire
import WebKit
import RxSwift

class ViewController: NSViewController,ApplicationDelegate{
    var wkWebView: WKWebView? = nil
    var fileList : [String]?
    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!
    var controllerShared:ViewController!
    

    override func viewWillAppear() {
        
        self.initStatusBar()
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.title = "code-tools"
        self.view.window?.titleVisibility = .hidden
        self.view.window?.minSize = NSSize(width: 960, height: 480)
        self.view.window!.setContentSize(NSSize(width: 960, height: 480))
        let delegate = NSApplication.shared.delegate as! AppDelegate
        delegate.setApplicationDelegate(self)
        self.initPreferenceButton()
        
        
    }
    
    @objc func showSettingView(_ task:NSMenuItem) {
        self.wkWebView?.evaluateJavaScript("showSettingView()", completionHandler: nil)
    }
    
    @objc func showDialog() {
        self.wkWebView?.evaluateJavaScript("openDialog('有执行中的任务，是否确定g终止这些任务？')", completionHandler: nil)
    }
    
    func closeApplication() {
        NSApplication.shared.terminate(true)
    }
    
    func initStatusBar() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.title = "N"
        if let button = statusBarItem.button {
            button.target = self
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func initPreferenceButton() {
        let items = NSApplication.shared.mainMenu?.items
        for item in items! {
            if (item.title != "Window") {
                let subMenu = item.submenu?.items
                for sub in subMenu! {
                    if sub.title == "Preferences…" {
                        sub.action = #selector(showSettingView)
                    }
                }
            }
        }
    }

    
    override func viewDidAppear() {
        self.initWebView()
        let _ = ShellEnviConf.init()
        self.initRunngingList()
        let _ = self.initDirectory()
//        let task = TaskList.init()
//        task.addTask(tag: "停止", task: Process())
//        addStatusBar(tastList: task)
        
        
//        let menuItem = NSMenuItem()
////        menuItem.submenu = submenu
//        menuItem.title = "停止"
//        menuItem.action = #selector(ternimalTask(_:))
//        menuItem.tag
//        self.statusBarMenu?.addItem(menuItem)
    }
    
    func addStatusBar(tastList:TaskList) {
        print("addStatusBar")
        self.statusBarMenu?.removeAllItems()
        for item in tastList.list {
            // 项目子menu
            print("add status bar \(tastList.list.count) \(item.key)")
            let submenu = NSMenu(title: "submenu")
            // 子项目按钮
            let menuItemStop = NSMenuItem()
            menuItemStop.title = "停止"
            
//            menuItemStop.action = #selector(ternimalTask(_:))
            menuItemStop.isEnabled = true
            submenu.addItem(menuItemStop)
            
            // 项目名称的item
            let menuItem = NSMenuItem()
            menuItem.submenu = submenu
            menuItem.title = item.value.tag!
//            menuItem.action = #selector(ternimalTask(_:))
            self.statusBarMenu?.addItem(menuItem)
        }
        
    }
    
}


// 选择目录相关操作
extension ViewController {
    
    // 初始化目录选择
    func initDirectory() -> String{
        if let recentlyUrl = UserDefaults.standard.string(forKey: CodeToolsConf.USER_DEFAULT_ROOT_DIRECTORY) {
            return recentlyUrl
        } else {
            self.chooseDir(type: "root")
            return ""
        }
    }
    
    // 选择目录
    func chooseDir(type: String) {
        let dialog = NSOpenPanel()
        dialog.canChooseDirectories = true
        dialog.begin(completionHandler: {
            response in
            if (response.rawValue == 0){
                return
            }
            if dialog.urls.count > 0 {
                self.savePathChanged(type: type, path: dialog.urls[0].path)
            }
        })
    }
    
    func savePathChanged(type: String,path: String) {
        switch type {
        case "root":
            UserDefaults.standard.set(path, forKey: CodeToolsConf.USER_DEFAULT_ROOT_DIRECTORY)
            self.wkWebView!.execJavaScript(funcName: "onSettingChanged", content:["rootPath": path].toJSONString()!)
            break
        case "ide":
            UserDefaults.standard.set(path, forKey: CodeToolsConf.USER_DEFAULT_IDE_PATH)
            self.wkWebView!.execJavaScript(funcName: "onSettingChanged", content:["idePath": path].toJSONString()!)
            break
        case "terminal":
            UserDefaults.standard.set(path, forKey: CodeToolsConf.USER_DEFAULT_TERMINAL_PATH)
            self.wkWebView!.execJavaScript(funcName: "onSettingChanged", content:["terminalPath": path].toJSONString()!)
            break
        default:
            break
        }
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
                fileList.append(model.toJSONString())
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
        self.loadJsFunction("swiftLoadFolderDetail", content: model.toJSONString())
    }
}
