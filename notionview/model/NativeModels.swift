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
    
    func addTask(_ task:Process) -> String{
        let timeInterval: TimeInterval = Date.init().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let tag = String(timeStamp)
        var taskModel = TaskModel()
        taskModel.tag = tag
        taskModel.task = task
        self.list[tag] = taskModel
        return tag
    }
}
