//
//  MailUtil.swift
//  Urgent
//
//  Created by jang gukjin on 6/5/24.
//  Copyright © 2024 jang gukjin. All rights reserved.
//

import Foundation
import MessageUI

class MailUtil: NSObject, MFMailComposeViewControllerDelegate {
    // MARK: Property --------------------
    let adminMail: String = App.const.adminMail
    let subject: String = App.const.mailSubject
    let body: String = App.const.mailBody
    let mailFailMessageTitle: String = App.const.mailFailMessageTitle
    let mailFailMessageBody: String = App.const.mailFailMessageBody
    
    // MARK: Logic --------------------
    func sendEmail() {
        let gmailURLString = "googlegmail:///co?to=\(adminMail)&subject=\(subject)&body=\(body)"
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([adminMail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            
            App.ui.topViewController?.present(mail, animated: true)
        } else if let gmailURL = URL(string: gmailURLString), UIApplication.shared.canOpenURL(gmailURL) {
                UIApplication.shared.open(gmailURL, options: [:], completionHandler: nil)
        } else {
            App.ui.alert(title: mailFailMessageTitle, message: mailFailMessageBody, actionTitle: "메일주소 복사하기", action: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.adminMail
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
