//
//  Double+Extension.swift
//  Urgent
//
//  Created by jang gukjin on 6/6/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation

extension Double {
    var toAllNumberInt: Int {
        let string: String = "\(self)".components(separatedBy: ".").joined()
        return Int(string) ?? Int(self)
    }
}
