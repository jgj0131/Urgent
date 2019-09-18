//
//  CardViewController.swift
//  Urgent
//
//  Created by jang gukjin on 16/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import MessageUI
import UIKit
import UserNotifications

class CardViewController: UIViewController {
    // MARK: Properties
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var latitudeAndLongitude: String?
    var secondTimer: Timer?
    var number = 0.0
    
    // MARK: IBOutlet
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var restroomSubTitle: UILabel!
    @IBOutlet weak var restroomAddress: UILabel!
    @IBOutlet weak var publicManAndWoman: UILabel!
    @IBOutlet weak var openingTime: UILabel!
    @IBOutlet weak var manToiletCount: UILabel!
    @IBOutlet weak var disabledManToiletCount: UILabel!
    @IBOutlet weak var womanToiletCount: UILabel!
    @IBOutlet weak var disabledWomanToiletCount: UILabel!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var backgroundArea: UIView!
    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var handleBar: UIView!
    
    // MARK: IBOutlet Collection
    @IBOutlet var titles: [UILabel]!
    
    // MARK: IBAction
    @IBAction func pushUseButton(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
        guard MFMessageComposeViewController.canSendText() else {
            print("메세지를 보낼 수 없습니다.")
            return
        }
    
        let userContacts = contacts.map() { $0["phone"]! }
        let timerText = (Int(timerData) / 3600 == 0 ? "" : "\(Int(timerData) / 3600) 시간 ") + "\((Int(timerData) % 3600) / 60)분"
    
        let messageViewController = MFMessageComposeViewController()
        messageViewController.messageComposeDelegate = self
        messageViewController.recipients = userContacts
        
        if sender.currentTitle == "위험대비문자 발송", userContacts.count >= 1, onOffStatus == true {
            messageViewController.body = """
            [급해(App)]
            화장실명: \(restroomName.text!)
            주소: \(restroomAddress.text!)
            위경도: \(latitudeAndLongitude!)
            날짜 및 시간: \(dateFormatter.string(from: Date()))
            화장실에 용무를 보기 전 불안하여 연락드립니다.
            \(timerText) 이내에 응답이 없으면 경찰서에 연락 부탁드립니다.
            """
            
            present(messageViewController, animated: true, completion: nil)
            
        } else if sender.currentTitle == "안심문자 발송", userContacts.count >= 1, onOffStatus == true {
            messageViewController.body = """
            [급해(App)]
            무사히 용무를 마쳤습니다. 걱정 안 하셔도 됩니다.
            감사합니다.
            """
            
            present(messageViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Objc Method
    @objc
    func timeCallback() {
        number += 1
        print(number)
        if number == timerData - 300 {
            notificate()
        } else if number == timerData, useButton.currentTitle == "안심문자 발송"{
            useButton.setTitle("위험대비문자 발송", for: .normal)
        }
    }
    
    // MARK: LifeCyvle
    override func viewDidLoad() {
        self.backgroundArea.layer.cornerRadius = 15
        self.handleArea.layer.cornerRadius = 15
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {(didAllow, error) in })
        UNUserNotificationCenter.current().delegate = self
  
        self.backgroundArea.layer.shadowColor = UIColor.black.cgColor
        self.backgroundArea.layer.shadowOpacity = 0.2
        self.backgroundArea.layer.shadowOffset = .zero
        self.backgroundArea.layer.shadowRadius = 3

        self.backgroundArea.layer.shadowPath = UIBezierPath(rect: backgroundArea.bounds).cgPath
        self.backgroundArea.layer.shouldRasterize = true
        self.backgroundArea.layer.rasterizationScale = UIScreen.main.scale
        
        self.handleBar.layer.cornerRadius = handleBar.frame.height/4
        let inputTitle = ["남녀공용여부:", "운영시간:", "남성용 대변기수:", "남성용 장애인 대변기수:", "여성용 대변기수:", "여성용 장애인 대변기수:"]
        super.viewDidLoad()
        addressTitle.text = "주소:"
        addressTitle.font = UIFont.boldSystemFont(ofSize: 17.0)
        useButton.roundedCorner()
        for index in 0..<titles.count {
            titles[index].text = inputTitle[index]
            titles[index].font = UIFont.boldSystemFont(ofSize: 17.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        onOffStatus = UserDefaults.standard.bool(forKey: "OnOffSwitch")
        timerData = UserDefaults.standard.double(forKey: "Timer")
        contacts = UserDefaults.standard.object(forKey: "Contacts") as? [[String : String]] ?? [[String:String]]()
    }
    
    // View가 Load 되었을 때 데이터들을 불러오는 메소드
    func output(data: [String:String]) {
        print(isViewLoaded)
        guard self.isViewLoaded == true else {
            return
        }
        sendData(data: data)
    }
    
    func notificate() {
        let content = UNMutableNotificationContent()
        content.title = "5분 남았습니다."
//        content.subtitle = "This is Subtitle : UserNotifications tutorial"
        content.body = "화장실 이용은 잘 하셨나요? 혹시 안심문자를 보내지 않았다면 지금 보내주세요"
        
        let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(index)timerdone", content: content, trigger: TimeIntervalTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

// MARK: Extension
extension UIButton {
    func roundedCorner() {
        self.layer.cornerRadius = self.frame.height/4
    }
}

extension CardViewController: SendDataDelegate {
    func sendData(data: [String:String]) {
        restroomName.text = data["화장실명"] == "" ? "정보없음" : data["화장실명"]
        restroomSubTitle.text = data["구분"] == "" ? "정보없음" : data["구분"]
        restroomAddress.text = data["소재지도로명주소"] == "" ? "정보없음" : data["소재지도로명주소"]!
        restroomAddress.numberOfLines = 0
        publicManAndWoman.text = data["남녀공용화장실여부"] == "" ? "정보없음" : data["남녀공용화장실여부"]!
        openingTime.text = data["개방시간"] == "" ? "정보없음" : data["개방시간"]!
        openingTime.numberOfLines = 0
        manToiletCount.text = data["남성용-대변기수"] == "" ? "정보없음" : data["남성용-대변기수"]!
        disabledManToiletCount.text = data["남성용-장애인용대변기수"] == "" ? "정보없음" : data["남성용-장애인용대변기수"]!
        womanToiletCount.text = data["여성용-대변기수"] == "" ? "정보없음" : data["여성용-대변기수"]!
        disabledWomanToiletCount.text = data["여성용-장애인용대변기수"] == "" ? "정보없음" : data["여성용-장애인용대변기수"]!
        useButton.setTitle("위험대비문자 발송", for: .normal)
        latitudeAndLongitude = "\(data["위도"]!), \(data["경도"]!)"
    }
}

extension CardViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            dismiss(animated: true, completion: nil)
            if useButton.currentTitle == "위험대비문자 발송" {
                useButton.setTitle("안심문자 발송", for: .normal)
                backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
                })
                if let timer = secondTimer {
                    if !timer.isValid {
                        secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCallback), userInfo: nil, repeats: true)
                    }
                } else {
                    secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCallback), userInfo: nil, repeats: true)
                }
            } else if useButton.currentTitle == "안심문자 발송"{
                useButton.setTitle("위험대비문자 발송", for: .normal)
                if let timer = secondTimer {
                    if timer.isValid {
                        timer.invalidate()
                    }
                }
                number = 0
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

extension CardViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        self.present(settingsViewController, animated: true, completion: nil)
    }
}
