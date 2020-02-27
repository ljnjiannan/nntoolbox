//
//  EvniromentConf.swift
//  notionview
//
//  Created by jiannan liu on 2019/12/31.
//  Copyright © 2019 jiannan liu. All rights reserved.
//
// 各类系统p版本


struct EnviStruct {
    let version:String
    let isInstall:Bool
    let command:String
    
    init?(_ command:String) {
        self.command = command
        let (status, result) = ShellUtil.shared.sync(command: command)
        if status == 0 {
            isInstall = true
            version = result
        } else {
            isInstall = false
        }
        return nil
    }
}

/**
 各类系统配置
 */
import Foundation
import RxSwift
class ShellEnviConf{
    var pythonEnv:EnviStruct? = nil
    var gitEnv:EnviStruct? = nil
    var nodeEnv:EnviStruct? = nil
    
    init() {
        pythonEnv = EnviStruct.init("python --version")
        gitEnv = EnviStruct.init("git --version")
        nodeEnv = EnviStruct.init("node --version")
    }
}


