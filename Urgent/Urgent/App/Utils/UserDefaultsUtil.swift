//
//  UserDefaultsUtil.swift
//  Urgent
//
//  Created by jang gukjin on 10/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation

struct UserDefaultsUtil {
    enum Key: String {
        case emergencyBellImageName
    }
    
    func set(key: Key, value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func get(key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
}
