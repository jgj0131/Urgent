//
//  RestroomDataSource.swift
//  Urgent
//
//  Created by jang gukjin on 11/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import Foundation

struct RestroomDataSource {
    func getSwiftArrayFromPlist(name: String) -> Array<Dictionary<String,String>> {
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        var arr: NSArray?
        arr = NSArray(contentsOfFile: path!)
        return (arr as? Array<Dictionary<String,String>>)!
    }
    
    func getDataForFata() -> Array<[String:String]> {
        let array = getSwiftArrayFromPlist(name: "toilet_20240530")
        let filteredArray = array.filter { $0["위도"] != "" && $0["경도"] != "" }
        return filteredArray
    }
}
