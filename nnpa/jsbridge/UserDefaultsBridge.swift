//
//  UserDefaultsBridge.swift
//  notionview
//
//  Created by jiannan liu on 2020/1/15.
//  Copyright © 2020 jiannan liu. All rights reserved.
//

import Foundation

protocol UserDefaultsBridgeProtocol {
    func getUserDefaultsDictionary(key:String) -> Dictionary<String, Any>
    func getUserDefaultsArray(key:String) -> [Any]
    func setUserDefaultsArray(key:String, value:Any) -> [Any]
    func removeUserDefaultsArray(key:String, index:Int) -> [Any]
}

class UserDefaultsBridge: UserDefaultsBridgeProtocol {

    func getUserDefaultsDictionary(key: String) -> Dictionary<String, Any> {
//        UserDefaults.standard.set([], forKey: key)
        if let result = UserDefaults.standard.dictionary(forKey: key) {
            return result
        }
        return [:]
    }
    
    func getUserDefaultsArray(key: String) -> [Any] {
        if let result = UserDefaults.standard.array(forKey: key) {
            return result
        }
        return []
    }
    
    func setUserDefaultsArray(key: String, value: Any) -> [Any] {
        return UserDefaults.standard.setArray(key: key, value: value)
    }
    
    func removeUserDefaultsArray(key: String, index: Int) -> [Any] {
        return UserDefaults.standard.removeFromArray(key: key, index: index)
    }
}
