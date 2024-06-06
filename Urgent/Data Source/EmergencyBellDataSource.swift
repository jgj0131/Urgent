//
//  EmergencyBellDataSource.swift
//  Urgent
//
//  Created by jang gukjin on 5/31/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation

struct EmergencyBellDataSource {
    func getSwiftArrayFromPlist(name: String) -> Array<Dictionary<String,String>> {
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        var arr: NSArray?
        arr = NSArray(contentsOfFile: path!)
        return (arr as? Array<Dictionary<String,String>>)!
    }
    
    func getDataForFata() -> Array<[String:String]> {
        let array = getSwiftArrayFromPlist(name: "emergencybell_20240531")
        let filteredArray = array.filter { isCorrectData($0) }
        return filteredArray
    }
    
    private func isCorrectData(_ data: [String: String]) -> Bool {
        guard let lat = data["위도"]?.toDouble, let long = data["경도"]?.toDouble else { return false }
        
        if lat >= 33, lat <= 39, long >= 124, long <= 132 {
            return true
        } else {
            return false
        }
    }
}
