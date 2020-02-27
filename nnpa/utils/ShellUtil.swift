//
//  ShellUtil.swift
//  notionview
//
//  Created by jiannan liu on 2019/12/3.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation
import RxSwift


class ShellUtil {
    let ENVI_PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    var taskList:TaskList = TaskList()
    
    static var shared : ShellUtil {
        struct Static {
            static let instance : ShellUtil = ShellUtil.init()
        }
        return Static.instance
    }
    
    /** 同步执行
     *  command:    shell 命令内容
     *  returns:    命令行执行结果，积压在一起返回
     *
     */
    func sync(command: String) -> (Int, String) {
        let utf8Command = "export LANG=en_US.UTF-8\n" + command
        return sync(shellPath: "/bin/bash", arguments: ["-c", utf8Command])
    }
    
    /** y异步执行
     *  script:    shell 命令内容
     *  name 执行的项目名称
     *  output 执行输出信息回调
     *  terminate: 命令终止回调
     */
    func async(script: String,name: String,command: String,
                          output: ((TaskOutputModel) -> Void)? = nil,
                          terminate: ((String) -> Void)? = nil) {
        async(shellPath: "/bin/zsh",name: name, arguments: ["-c", script],command: command, output:output, terminate:terminate)
    }
    
    /** 将异步执行的项目加入历史记录
     *  tag 项目名称
     *  script 执行的命令
     */
    func addToHistory(tag:String,script:String,command:String,pid:Int) -> Void {
        self.taskList.addHistory(tag: tag, script: script,command: command)
        UserDefaults.standard.setHistory(key:CodeToolsConf.USER_DEFAULT_HISTORY,tag: tag, value: ["tag": tag, "script": script,"command": command,"time": Int(Date().timeIntervalSince1970),"pid":pid])
    }
    
    /** 终止异步命令
     *  tag 项目名称
     */
    func terminateTask(id:String) -> Void {
        self.taskList.removeTask(id: id)
    }
    
    func setRunningTask(tag:String, id: Int32) {
        UserDefaults.standard.set(id, forKey: CodeToolsConf.USER_DEFAULT_RUNNING_PROJECT)
    }
    
    func async(shellPath: String, name: String,
                      arguments: [String]? = nil,
                      command:String,
                      output: ((TaskOutputModel) -> Void)? = nil,
                      terminate: ((String) -> Void)? = nil) {
        DispatchQueue.global().async {
            let task = Process()
            let tag = self.taskList.addTask(tag: name, task: task,command: command,pid: "")
            let pipe = Pipe()
            let outHandle = pipe.fileHandleForReading
            
            var environment = ProcessInfo.processInfo.environment
            environment["PATH"] = self.ENVI_PATH
            task.environment = environment
            
            if arguments != nil {
                task.arguments = arguments!
            }
            
            task.launchPath = shellPath
            task.standardOutput = pipe
            
            outHandle.waitForDataInBackgroundAndNotify()
            var obs1 : NSObjectProtocol!
            obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                  object: outHandle, queue: nil) {  notification -> Void in
                    let data = outHandle.availableData
                    if data.count > 0 {
                        if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            DispatchQueue.main.async {
                                var out = TaskOutputModel()
                                out.tag = tag
                                out.content = str as String
                                self.taskList.addLogs(id: TaskUtil.getTaskId(tag: name, command: command), content: str as String)
                                output?(out)
                            }
                        }
                        outHandle.waitForDataInBackgroundAndNotify()
                    } else {
                        NotificationCenter.default.removeObserver(obs1 as Any)
                        let data = pipe.fileHandleForReading.readDataToEndOfFile()
                         let _: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                        pipe.fileHandleForReading.closeFile()
                    }
            }
            
            var obs2 : NSObjectProtocol!
            obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                  object: task, queue: nil) { notification -> Void in
                    DispatchQueue.main.async {
                        terminate?(tag)
                        self.taskList.removeTask(id: TaskUtil.getTaskId(tag: name, command: command))
                    }
                    NotificationCenter.default.removeObserver(obs2 as Any)
            }
            
            task.launch()
            
            self.addToHistory(tag: name, script: arguments![1],command: command,pid: Int(task.processIdentifier))
            task.waitUntilExit()
        }
    }


    /** 同步执行
     *  shellPath:  命令行启动路径
     *  arguments:  命令行参数
     *  returns:    命令行执行结果，积压在一起返回
     *
     */
    func sync(shellPath: String, arguments: [String]? = nil) -> (Int, String) {
        let task = Process()
        let pipe = Pipe()
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        task.environment = environment
        
        if arguments != nil {
            task.arguments = arguments!
        }
        task.launchPath = shellPath
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding.utf8)!
        task.waitUntilExit()
        pipe.fileHandleForReading.closeFile()
        return (Int(task.terminationStatus), output)
    }
    


}
