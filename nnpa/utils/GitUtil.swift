//
//  GitUtil.swift
//  notionview
//
//  Created by jiannan liu on 2019/12/31.
//  Copyright © 2019 jiannan liu. All rights reserved.
//

import Foundation

class GitUtil {
    
    static func getBranchs(_ path:String) -> String {
        let (status, result) = ShellUtil.shared.sync(command: "cd \(path) && git branch -a")
        if (status == 0) {
            var model = GitBranchModel()
            let ts = result.split(separator: "\n").map{$0.trimmingCharacters(in: .whitespaces)}
            for item in ts {
                if item.starts(with: "*") {
                    let follow = self.getBranchFolllowInfo(path).replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                    var followBranch = ""
                    var followInfo = ""
                    if follow != "" && follow.split(separator: ":").count > 1 {
                        followBranch = String(follow.split(separator: ":")[0])
                        followInfo = String(follow.split(separator: ":")[1])
                    } else {
                        followBranch = follow
                    }
                    model.current = ["branch": item, "follow": followBranch, "info": followInfo].toJSONString()
                }
                if (item.split(separator: "/").count > 1) {
                    model.remote.append(String(item.suffix(item.count - 8)))
                } else {
                    model.locals.append(item)
                }
            }
            return model.toJSONString()
        }
        return "{}"
    }
    
    static func getStatusInfo(_ path:String) -> String {
        let (status, result) = ShellUtil.shared.sync(command: "cd \(path) && git status -s")
        if (status == 0) {
            var model = GitStatusModel()
            let ts = result.split(separator: "\n")
//                .map{$0.trimmingCharacters(in: .whitespaces)}
            for item in ts {
                if item.starts(with: "M ") {
                    model.modifyFile.append(String(item.suffix(item.count - 3)))
                } else if item.starts(with: "D") {
                    model.deleteFile.append(String(item.suffix(item.count - 3)))
                } else if item.starts(with: "MM") || item.starts(with: " M") {
                    model.rakeFile.append(String(item.suffix(item.count - 3)))
                 }else if item.starts(with: "T") {
                    model.typeModifyFile.append(String(item.suffix(item.count - 3)))
                } else if item.starts(with: "U") {
                    model.unmergedFile.append(String(item.suffix(item.count - 3)))
                } else if item.starts(with: "??") {
                    model.newFile.append(String(item.suffix(item.count - 3)))
                }
                
            }
            return model.toJSONString()
        }
        return "{}"
    }
    
    static func getStatusInfoList(_ path:String) -> [String] {
        let (status, result) = ShellUtil.shared.sync(command: "cd \(path) && git status -s")
        if (status == 0) {
            var list:[String] = []
            let ts = result.split(separator: "\n")
//                .map{$0.trimmingCharacters(in: .whitespaces)}
            for item in ts {
                var model = GittatusInfoModel()
                model.path = String(item.suffix(item.count - 3))
                model.type = String(item.prefix(2))
                list.append(model.toJSONString())
            }
            return list
        }
        return []
    }
    
    
    static func getBranchFolllowInfo(_ path:String) -> String {
        let (status, result) = ShellUtil.shared.sync(command: "cd \(path) && git branch -vv")
        if (status == 0) {
            let ts = result.split(separator: "\n").map{$0.trimmingCharacters(in: .whitespaces)}
            for item in ts {
                if item.split(separator: " ").count > 1 && item.starts(with: "* ") {
                    let pattern = "\\[.*\\]"
                    let regex = try? NSRegularExpression(pattern: pattern, options: [])
                    if let results = regex?.matches(in: item, options: [], range: NSRange(location: 0, length: item.count)), results.count != 0 {
                        if results.count != 0 {
                            return (item as NSString).substring(with: results[0].range)
                        }
                    }
                }
            }
            
        }
        return ""
    }
    
    static func followBranch(_ path:String,remote:String,current:String) {
        let _ = ShellUtil.shared.sync(command: "cd \(path) && git branch --set-upstream-to=\(remote) \(current)")
    }
    
    static func addAll(_ path:String) {
        let _ = ShellUtil.shared.sync(command: "cd \(path) && git add .")
    }

    static func commit(_ path:String,_ message:String) {
        let _ = ShellUtil.shared.sync(command: "cd \(path) && git commit -m \(message)")
    }

    static func push(_ path:String,_ remote:String) {
        let _ = ShellUtil.shared.sync(command: "cd \(path) && git push \(remote)")
    }
    
}
