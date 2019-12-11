//
//  DirectorListModel.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/28.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

struct DirectorListModel:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var name:String?
    var path:String?
    var isFolder:Bool?
    var git:Bool?
    var folderType:String?
    
}

struct FolderDetailModel:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var name:String?
    var size:Int32?
    var createDate:String?
    var modifyDate:String?
    var nodejs:String?
    var path:String?
    var isRunninng:Bool?
}

struct NodejsInfo:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var isNodejs:Bool?
    var runConmands:[String]?
}
