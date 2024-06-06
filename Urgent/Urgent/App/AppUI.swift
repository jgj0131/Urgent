//
//  AppUI.swift
//  Urgent
//
//  Created by jang gukjin on 6/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation
import UIKit

final class AppUI {
    var rootviewController: UIViewController? {
        return App.appDelegate?.window?.rootViewController
    }
    
    var topViewController: UIViewController? {
        if let presented = rootviewController?.presentedViewController {
            return presented
        } else {
            return rootviewController
        }
    }
}

// MARK: Alert --------------------
extension AppUI {
    func alert(title: String? = nil, message: String?, actionTitle: String = "확인", isCancellable: Bool = false, action: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if isCancellable {
            let cancelAction: UIAlertAction = .init(title: "닫기", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.urgent, forKey: "titleTextColor")
            alert.addAction(cancelAction)
        }
        
        let okAction: UIAlertAction = .init(title: actionTitle, style: .default, handler: action)
        okAction.setValue(UIColor.ccGreen, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        topViewController?.present(alert, animated: true, completion: nil)
    }
}
