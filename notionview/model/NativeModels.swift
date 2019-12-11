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
}

struct TaskListInfo:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var name:String?
    var log:String?
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
    
    func addTask(tag: String,task: Process) -> String{
        let tag = tag
        var taskModel = TaskModel()
        taskModel.tag = tag
        taskModel.task = task
        self.list[tag] = taskModel
        return tag
    }
    
    func removeTask(tag: String) -> Void {
        let task = self.list[tag]?.task
        task?.terminate()
        self.list.removeValue(forKey: tag)
    }
    
    func removeAllTask() {
        for item in self.list {
            self.removeTask(tag: item.key)
        }
    }
    
    func addLogs(_ tag:String,content:String) {
        var task = self.list[tag]
        let tags = task?.logs
        var model = TaskOutputModel()
        if let lastContent = tags?.content {
            model.content = lastContent + "\(content)</br>"
        } else {
            model.content = "\(content)</br>"
        }
        
        model.tag = tag
        task?.logs = model
        self.list[tag] = task
//        task?.logs?.content = "\(task?.logs?.content) \(content)"
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
    
    func isRunning(_ path:String) -> Bool {
        return self.list.contains(where: {(key, value) in
            return key == path
        })
    }
}
