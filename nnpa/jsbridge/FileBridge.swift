//
//  FileBridge.swift
//  notionview
//
//  Created by jiannan liu on 2020/1/15.
//  Copyright © 2020 jiannan liu. All rights reserved.
//

import Foundation

protocol FileBridgeProtocol {
    // 获取文件目录列表
    func getDirectorys(path: String) -> Dictionary<String, Any>
    // 获取文件目录详情
    func getDirectoryDetail(path: String) -> FolderDetailModel
}

class FileBridge: FileBridgeProtocol {
    
    func getDirectorys(path: String) -> Dictionary<String, Any> {
        do {
            let dir = try FileManager.default.contentsOfDirectory(atPath: path).filter{
                item in
                let filterList = [".DS_Store", ".git", ".gitignore"]
                return !filterList.contains(item)
            }
            
            var fileList = [String]()
            for filename in dir {
                var model = DirectorListModel()
                model.name = filename
                model.path = "\(path)/\(filename)"
                model.isFolder = FileManager.isDirector(path: model.path!)
                model.git = FileManager.isGitDirector(model.path!)
                model.folderType = FileManager.directorType(model.path!)
                fileList.append(model.toJSONString())
            }
            let dic = [
                "list": fileList,
                "path": path
                ] as [String : Any]
            return dic
        }catch let err as NSError {
            print(err)
        }
        return [:]
    }
    
    func getDirectoryDetail(path: String) -> FolderDetailModel {
        return FileManager.folderDetail(path)
    }
}
