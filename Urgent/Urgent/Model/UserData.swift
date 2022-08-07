//
//  UserData.swift
//  Urgent
//
//  Created by jang gukjin on 09/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import Foundation

protocol ContactsDelegate {
    func add(data: [String:String])
}

struct UserData {
    private var activation: Bool = true
    private var time: Timer = Timer()
    private var contacts: [String] = []
}
