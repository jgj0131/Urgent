//
//  RestroomDataSource.swift
//  Urgent
//
//  Created by jang gukjin on 11/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import Foundation

struct Excel {
    func getSwiftArrayFromPlist(name: String) -> Array<Dictionary<String,String>> {
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        var arr: NSArray?
        arr = NSArray(contentsOfFile: path!)
        return (arr as? Array<Dictionary<String,String>>)!
    }
    
    func getDataForFata(data: String) -> Array<[String:String]> {
        let array = getSwiftArrayFromPlist(name: "NationalPublicRestroomData")
        //let namePredicate = NSPredicate(format: "화장실명", data)
        return array//[array.filter {namePredicate.evaluate(with: $0)}[0]]
    }
}
