//
//  CompleteAlertViewController.swift
//  Urgent
//
//  Created by jang gukjin on 2022/08/10.
//  Copyright © 2022 jang gukjin. All rights reserved.
//

import UIKit
import MessageUI
import Lottie

class CompleteAlertViewController: UIViewController {
    // MARK: Properties
    let animationView: AnimationView = .init(name: "complete")
    let alertView: UIView = .init()
    let alertLabel:UILabel = .init()
    let sendMessageButton: UIButton = .init()
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView: UIVisualEffectView = .init(effect: blurEffect)
        return blurView
    }()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(playAnimation), name: NSNotification.Name("playAnimation"), object: nil)
        
        setView()
        
        if !UserDefaults.standard.bool(forKey: "sentHelpMessage") {
            DispatchQueue.main.async {
                self.dismiss(animated: false)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.view.backgroundColor = .black.withAlphaComponent(0.3)
            self.visualEffectView.isHidden = false
        })
    }
    
    // MARK: Custom Method
    func setView() {
        
        let tapSendMessageButton: UITapGestureRecognizer = .init(target: self, action: #selector(sendCompleteButton))
        
        view.addSubview(visualEffectView)
        view.addSubview(alertView)
        
        visualEffectView.frame = self.view.frame
        visualEffectView.isHidden = true
        
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        alertView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        alertView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        alertView.heightAnchor.constraint(equalToConstant: 270).isActive = true
        alertView.backgroundColor = .systemBackground
        alertView.layer.cornerRadius = 15

        alertView.addSubview(animationView)
        alertView.addSubview(alertLabel)
        alertView.addSubview(sendMessageButton)

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 60, y: 10, width: 80, height: 80)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 5).isActive = true
        alertLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -10).isActive = true
        alertLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 10).isActive = true
        alertLabel.bottomAnchor.constraint(equalTo: sendMessageButton.topAnchor, constant: -10).isActive = true
        alertLabel.text = "화장실은 잘 이용하셨나요?\n\n사랑하는 사람들이 걱정하지 않도록\n안심 문자를 보내주세요!"
        alertLabel.font = UIFont(name: "Avenir Book", size: 15)
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 4
        alertLabel.textColor = .label

        sendMessageButton.translatesAutoresizingMaskIntoConstraints = false
        sendMessageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendMessageButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -10).isActive = true
        sendMessageButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 10).isActive = true
        sendMessageButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -15).isActive = true
        sendMessageButton.backgroundColor = UIColor(red: 22/255, green: 231/255, blue: 207/255, alpha: 1)
        sendMessageButton.setTitle("안심 문자 보내기", for: .normal)
        sendMessageButton.titleLabel?.font = UIFont(name: "Avenir Black", size: 18)
        sendMessageButton.setTitleColor(.white, for: .normal)
        sendMessageButton.addGestureRecognizer(tapSendMessageButton)
        sendMessageButton.layer.cornerRadius = 15
    }
    
    @objc
    func playAnimation(_ notification: Notification) {
        animationView.play()
    }
    
    /// 완료 메세지를 보냅니다.
    @objc
    func sendCompleteButton() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
        guard MFMessageComposeViewController.canSendText() else {
            print("메세지를 보낼 수 없습니다.")
            return
        }
    
        let savedContacts = UserDefaults.standard.object(forKey: "Contacts") as? [[String : String]] ?? [[String:String]]()
        let userContacts = savedContacts.map() { $0["phone"]! }
        let onOffStatus = UserDefaults.standard.bool(forKey: "OnOffSwitch")
        let timerText = (Int(timerData) / 3600 == 0 ? "" : "\(Int(timerData) / 3600) 시간 ") + "\((Int(timerData) % 3600) / 60)분"
    
        let messageViewController = MFMessageComposeViewController()
        messageViewController.messageComposeDelegate = self
        messageViewController.recipients = userContacts
        
        if userContacts.count >= 1, onOffStatus == true {
            messageViewController.body = """
            [급해(App)]
            무사히 용무를 마쳤습니다. 걱정 안 하셔도 됩니다.
            감사합니다.
            """
            
            present(messageViewController, animated: true, completion: nil)
        }
    }
}

// MARK: Extension - MFMessageComposeViewControllerDelegate
extension CompleteAlertViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            NotificationCenter.default.post(name: NSNotification.Name("sendMessage"), object: false)
            UserDefaults.standard.set(false, forKey: "sentHelpMessage")
            self.view.backgroundColor = .clear
            self.visualEffectView.isHidden = true
            dismiss(animated: true)
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        case .failed:
            print("failed")
            dismiss(animated: true, completion: nil)
        @unknown default:
            print("unkown Error")
            dismiss(animated: true, completion: nil)
        }
    }
}
