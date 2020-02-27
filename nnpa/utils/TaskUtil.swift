//
//  TaskUtil.swift
//  notionview
//
//  Created by jiannan liu on 2020/1/22.
//  Copyright © 2020 jiannan liu. All rights reserved.
//

import Foundation

class TaskUtil {
    
    static func getTaskId(tag: String, command:String) -> String{
        let taskString = "tag:\(tag);command:\(command)"
        return (taskString.data(using: String.Encoding.utf8)?.base64EncodedString())!
    }

}
