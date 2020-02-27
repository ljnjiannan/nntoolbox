//
//  File.swift
//  notionview
//
//  Created by jiannan liu on 2019/12/3.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

struct TaskModel {
    var tag:String?
    var task:Process?
    var logs:TaskOutputModel?
    var command:String?
    var pid:String?
    
    func toJson()->String {
        return ["tag": self.tag, "command": self.command,"pid": self.pid].toJSONString()!
    }
}

struct TaskListInfo:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var name:String?
    var log:String?
    var command:String?
}

struct TaskOutputModel:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var tag:String?
    var content:String?
}

class TaskList {
    var list:[String:TaskModel] = [:]
    var history:[String:String] = [:]
    
    
    func addTask(tag: String,task: Process?,command:String,pid:String) -> String{
        let id = TaskUtil.getTaskId(tag: tag, command: command)
        var taskModel = TaskModel()
        taskModel.tag = tag
        taskModel.task = task
        taskModel.command = command
        if (task != nil) {
            taskModel.pid = String(task!.processIdentifier)
        } else {
            taskModel.pid = pid
        }
        self.list[id] = taskModel
        return tag
    }
    
    func removeTask(id: String) -> Void {
        if let task = self.list[id]?.task {
            task.terminate()
        } else {
            if let pid = self.list[id]?.pid {
                let _ = ShellUtil.shared.sync(command: "kill \(pid)")
            }
        }
        self.list.removeValue(forKey: id)
    }
    
    func removeAllTask() {
        for item in self.list {
            self.removeTask(id: item.key)
        }
    }
    
    func addLogs(id:String,content:String) {
        var task = self.list[id]
        let logs = task?.logs
        var model = TaskOutputModel()
        if let lastContent = logs?.content {
            model.content = lastContent + "\(content)"
        } else {
            model.content = "\(content)"
        }
        model.tag = task?.tag
        task?.logs = model
        self.list[id] = task
    }
    
    func tuJsonString() -> String{
        let resultList: [String] = self.list.map{
            (item) in
            var model = TaskListInfo()
            model.name = item.key
            model.log = item.value.logs?.content
            return model.toJSONString()
        }
        return resultList.toJSONString()!
    }
    
    func getLogs() -> String{
        let resultList: [String] = self.list.map{
            (item) in
            var model = TaskListInfo()
            model.name = item.value.tag
            model.command = item.value.command
            model.log = item.value.logs?.content
            return model.toJSONString()
        }
        return resultList.toJSONString()!
    }
    
    func getLogs(id:String) -> String{
        if let item = self.list[id]?.logs {
            return (item.content)!
        }
        return ""
    }
    
    func isRunning(id:String) -> Bool {
        return self.list.contains(where: {(key, value) in
            return key == id
        })
    }
    
    func addHistory(tag:String, script:String,command: String) {
//        let id = TaskUtil.getTaskId(tag: tag, command: command)
        let content = ["script": script, "command": command].toJSONString()
        if (self.history.keys.contains(tag)) {
            self.history.updateValue(content!, forKey: tag)
        } else {
            self.history[tag] = content
        }
    }
    
    func getListJson() -> [String] {
        var result:[String] = []
        for item in self.list {
            let res = ["id": item.key,"tag": item.value.tag,"command":item.value.command].toJSONString()
            result.append(res!)
        }
        return result
    }
    
    
}
