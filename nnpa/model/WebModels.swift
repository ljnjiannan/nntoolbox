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
    var isNodejs:Bool?
    var path:String?
    var isRunninng:Bool?
    var isGit:Bool?
    
}

struct NodejsInfo:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var runConmands:[String]?
    var dependence:[String]?
    var devDependence:[String]?
    var runningScript:[String]?
}

struct GitBranchModel:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var current:String?
    var locals:[String] = []
    var remote:[String] = []
}

struct GittatusInfoModel:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    var type:String = ""
    var path:String = ""
}

struct GitStatusModel:Mappable {
    func modelMapFinished() {
    }
    
    func structMapFinished() {
    }
    
    // ?? 新增未跟踪
    var newFile:[String] = []
    // D 本地删除
    var deleteFile:[String] = []
    // M 文件内容或mode被修改
    var modifyFile:[String] = []
    // MM 尚未暂存以备提交的变更
    var rakeFile:[String] = []
    // T 文件类型被修改
    var typeModifyFile:[String] = []
    // U 文件未合并
    var unmergedFile:[String] = []
}
