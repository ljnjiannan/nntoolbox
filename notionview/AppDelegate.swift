//
//  AppDelegate.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/27.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        ShellUtil.shared.taskList.removeAllTask()
    }


}

