//
//  FileUtils.swift
//  notionview
//
//  Created by jiannan liu on 2019/11/28.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

import SwiftyJSON

extension FileManager{
    
    // d判断是否是文件夹
    static func isDirector(path:String) -> Bool{
        var directoryExists = ObjCBool.init(false)
        let fileExists = self.default.fileExists(atPath: path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
    
    // 读取json数据
    static func readLocalDataForJson(_ path:String) -> JSON? {
        //读取本地的文件
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            return try! JSON(data: data)
//            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
//            return jsonData;
        } catch let error as Error? {
            return JSON(["error":error?.localizedDescription]);
        }
    }
    
    // 判断是否是git
    static func isGitDirector(_ path:String) -> Bool {
        var isGit = false
        do {
            let dir = try self.default.contentsOfDirectory(atPath: path).filter{
                item in
                return item == ".git"
            }
            isGit = dir.count > 0
        } catch {}
        return isGit
    }
    
    // 获取代码仓库类型
    static func directorType(_ path:String) -> String {
        var type = ""
        do {
            let dir = try self.default.contentsOfDirectory(atPath: path)
            for item in dir {
                if (item == ".git") {
                    type = "git"
                    break
                } else if (item == ".svn") {
                    type = "svn"
                    break
                }
            }
        } catch {}
        return type
    }
    
    // 获取文件夹详情
    static func folderDetail(_ path:String) -> FolderDetailModel {
        var model = FolderDetailModel()
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize:NSNumber = attr[FileAttributeKey.size] as! NSNumber? {
                model.size = fileSize.int32Value
            }
            if let creationDate = attr[FileAttributeKey.creationDate] {
                let date = creationDate as! NSDate
                let stringDate = dateFormatter.string(from: date as Date)
                model.createDate = stringDate
             }
            if let modificationDate = attr[FileAttributeKey.modificationDate] {
               let date = modificationDate as! NSDate
               let stringDate = dateFormatter.string(from: date as Date)
               model.modifyDate = stringDate
            }
            model.path = path
            model.name = self.default.displayName(atPath: path)
//            let names = path.split(separator: "/")
//            if (names.count > 0) {
//                model.name = name
//            } else {
//                model.name = ""
//            }
            
            model.nodejs = try self.isNodejs(path).toJSONString()
            
        } catch {}
        return model
    }
    
    // 是否是nodejs项目
    static func isNodejs(_ path:String) -> NodejsInfo {
        var model = NodejsInfo()
        do {
            let dir = try self.default.contentsOfDirectory(atPath: path).filter{
                item in
                return item == "package.json"
            }
            model.isNodejs = dir.count > 0
            if model.isNodejs! {
                let jsonData = self.readLocalDataForJson(path+"/package.json")
                model.runConmands = jsonData!["scripts"].map{
                    item -> String in
                    return item.0
                }
            }
        } catch {}
        return model
    }
}
