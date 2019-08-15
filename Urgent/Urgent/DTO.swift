//
//  DTO.swift
//  Urgent
//
//  Created by jang gukjin on 14/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import Foundation

class DTO {
    var data: [String:String]
    
    init(_ data: [String:String]) {
        self.data = data
    }
    
    func getData() -> [String:String] {
        return data
    }
}
