//
//  App.swift
//  Urgent
//
//  Created by jang gukjin on 6/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation
import UIKit

struct App {
    static let const: AppConstant = .init()
    static let util: AppUtil = .init()
    
    static let ui = AppUI()
    
    // MARK: Delegate --------------------
    static var appDelegate: AppDelegate? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate
    }
}
