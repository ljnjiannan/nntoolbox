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
    var window: NSWindow?
    var ad:ApplicationDelegate?
    
    func setApplicationDelegate(_ ad:ApplicationDelegate) {
        self.ad = ad
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window = NSWindow(contentViewController: ViewController())
        window?.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
//        ShellUtil.shared.taskList.removeAllTask()
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if (ShellUtil.shared.taskList.list.count > 0) {
            if (ad != nil) {
                ad?.showDialog()
            }
            return NSApplication.TerminateReply.terminateCancel
        } else {
            return NSApplication.TerminateReply.terminateNow
        }
        
    }
    
    
    @objc func orderABurrito() {
        print("Ordering a burrito!")
    }


    @objc func cancelBurritoOrder() {
        print("Canceling your order :(")
    }



}

