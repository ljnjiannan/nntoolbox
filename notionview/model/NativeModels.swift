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
}
