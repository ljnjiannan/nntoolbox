//
//  UserDefaultsConf.swift
//  notionview
//
//  Created by jiannan liu on 2020/1/16.
//  Copyright © 2020 jiannan liu. All rights reserved.
//

import Foundation

extension UserDefaults{
    
    func setArray(key:String,value: Any) -> [Any]{
        if var arrays = self.array(forKey: key) {
            arrays.append(value)
            self.set(arrays, forKey: key)
        } else {
            self.set([value], forKey: key)
        }
        return self.array(forKey: key)!
    }
    
    func setHistory(key:String,tag:String, value: Dictionary<String, Any>) {
        if var dic = self.dictionary(forKey: key) {
            dic[tag] = value
            self.set(dic, forKey: key)
        } else {
            let dic = [tag: value]
            self.set(dic, forKey: key)
        }
    }
    
    func removeFromArray(key:String,index: Int) ->[Any] {
        if var array = self.array(forKey: key) {
            array.remove(at: index)
            self.set(array, forKey: key)
            return array
        }
        return self.array(forKey: key)!
    }
    
}
