//
//  Contacts.swift
//  Urgent
//
//  Created by jang gukjin on 09/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import Foundation

struct ContactStruct: Comparable {
    let givenName: String
    let familyName: String
    let number: String
    
    static func < (lhs: ContactStruct, rhs: ContactStruct) -> Bool {
        return lhs.givenName + lhs.familyName < rhs.givenName + rhs.familyName
    }
}
