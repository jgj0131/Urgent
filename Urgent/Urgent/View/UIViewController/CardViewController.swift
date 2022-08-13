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
import CoreLocation

class CardViewController: UIViewController {
    // MARK: Properties
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    private var latitudeAndLongitude: String?
//    private var secondTimer: Timer?
    private var number = 0.0
    var callNumber: String = "114"
    
    // MARK: IBOutlet
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var restroomSubTitle: UILabel!
    @IBOutlet weak var restroomAddress: UILabel!
    @IBOutlet weak var publicManAndWoman: UILabel!
    @IBOutlet weak var openingTime: UILabel!
    @IBOutlet weak var manToiletCount: UILabel!
    @IBOutlet weak var womanToiletCount: UILabel!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var backgroundArea: UIView!
    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var handleBar: UIView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var callButton: UIImageView!
    @IBOutlet weak var emergencyBellValue: UILabel!
    @IBOutlet weak var cctvValue: UILabel!
    @IBOutlet weak var diaperValue: UILabel!
    
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
    
        let userContacts = savedContacts.map() { $0["phone"]! }
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
        print("남은시간:\(UIApplication.shared.backgroundTimeRemaining)")
        if number == timerData - 300 {
            notificate()
        } else if number == timerData, useButton.currentTitle == "안심문자 발송"{
            useButton.setTitle("위험대비문자 발송", for: .normal)
            useButton.backgroundColor = UIColor(red: 254/255, green: 115/255, blue: 111/255, alpha: 1)
            UserDefaults.standard.set("위험대비문자 발송", forKey: "useButtonTitle")
//            gpsState = .off
        } else if number > timerData + 10 {
            self.endBackgroundTask()
        }
    }
    
    // MARK: LifeCyvle
    override func viewDidLoad() {
        self.backgroundArea.layer.cornerRadius = 20
        self.handleArea.layer.cornerRadius = 15
        
        useButton.titleLabel?.text = UserDefaults.standard.string(forKey: "useButtonTitle")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {(didAllow, error) in })
        UNUserNotificationCenter.current().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeUseButtonState(_:)), name: Notification.Name("useButtonState"), object: nil)
        
//        self.backgroundArea.layer.shadowColor = UIColor.label.cgColor
//        self.backgroundArea.layer.shadowOpacity = 0.5
//        self.backgroundArea.layer.shadowOffset = .zero
//        self.backgroundArea.layer.shadowRadius = 1
//
//        self.backgroundArea.layer.shadowPath = UIBezierPath(rect: backgroundArea.bounds).cgPath
        
        self.backgroundArea.layer.shouldRasterize = true
        self.backgroundArea.layer.rasterizationScale = UIScreen.main.scale
        
        let onOff = UserDefaults.standard.bool(forKey: "OnOffSwitch")
        if onOff {
            useButton.backgroundColor = .urgent
            useButton.isEnabled = true
        } else {
            useButton.backgroundColor = .gray
            useButton.isEnabled = false
        }
        
        self.handleBar.layer.cornerRadius = handleBar.frame.height/4
        let inputTitle = ["🚻", "🕖", "🚹", "🚺", "🚨", "📷", "👶🏻"]
        super.viewDidLoad()
        addressTitle.text = "🏠"
        addressTitle.font = UIFont.boldSystemFont(ofSize: 17.0)
        useButton.roundedCorner()
        for index in 0..<titles.count {
            titles[index].text = inputTitle[index]
//            titles[index].font = UIFont.boldSystemFont(ofSize: 17.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        onOffStatus = UserDefaults.standard.bool(forKey: "OnOffSwitch")
        timerData = UserDefaults.standard.double(forKey: "Timer")
        savedContacts = UserDefaults.standard.object(forKey: "Contacts") as? [[String : String]] ?? [[String:String]]()
        useButton.setTitle(UserDefaults.standard.string(forKey: "useButtonTitle"), for: .normal)
//        if useButton.currentTitle == "안심문자 발송" {
//            useButton.backgroundColor = UIColor(red: 74/255, green: 166/255, blue: 157/255, alpha: 1)
//        } else {
//            useButton.backgroundColor = UIColor(red: 254/255, green: 115/255, blue: 111/255, alpha: 1)
//        }
        
    }
    
    // MARK: Custom Method
    func setDistance(distance: CLLocationDistance) {
        let distanceInt: Int = Int(distance)
        let time: Int = Int(distanceInt / 66)
        var timeText: String = ""
        if time > 59 {
            timeText = "\(time/60)시간 \(time%60)분"
        } else {
            timeText = "\(time)분"
        }
        if distance > 1000 {
            self.distance.text = String(format: "%.1f", Double(distanceInt/1000)) + "km\n" + timeText
        } else {
            self.distance.text = "\(distanceInt)m\n" + timeText
        }
    }
    
    @objc
    func changeUseButtonState(_ notification: Notification) {
        if let state = notification.object as? Bool, state {
            useButton.backgroundColor = .urgent
            useButton.isEnabled = true
        } else {
            useButton.backgroundColor = .gray
            useButton.isEnabled = false
        }
    }
    
    /// interface의 변화에 따라 동작하는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("화면모드 변경")
//        if UIApplication.shared.applicationState == .active {
//            useButton.setTitle(UserDefaults.standard.string(forKey: "useButtonTitle"), for: .normal)
//        }
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
        content.body = "화장실 이용은 잘 하셨나요? 혹시 안심문자를 보내지 않았다면 지금 보내주세요"
        
        let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(String(describing: index))timerdone", content: content, trigger: TimeIntervalTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
//        secondTimer!.invalidate()
        number = 0
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        backgroundTaskIdentifier = .invalid
    }
    
    @objc
    func calling(_ sender: UITapGestureRecognizer) {
        
        // URLScheme 문자열을 통해 URL 인스턴스를 만들어 줍니다.
        if let url = NSURL(string: "tel://" + callNumber), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
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
        if data["소재지도로명주소"] == "" {
            if data["소재지지번주소"] == "" {
                restroomAddress.text = "정보없음"
            } else {
                restroomAddress.text = data["소재지지번주소"]!
            }
        } else {
            restroomAddress.text = data["소재지도로명주소"]!
        }
        restroomAddress.numberOfLines = 0
        publicManAndWoman.text = data["남녀공용화장실여부"] == "Y" ? "공용" : "남녀 분리"
        openingTime.text = (data["개방시간"] == "" || data["개방시간"] == ":~:") ? "정보없음" : data["개방시간"]!
        openingTime.numberOfLines = 0
        manToiletCount.text = ("일반: \(data["남성용-대변기수"] == "" ? "정보없음" : data["남성용-대변기수"]!) / 장애인용: \(data["남성용-장애인용대변기수"] == "" ? "정보없음" : data["남성용-장애인용대변기수"]!)")
        womanToiletCount.text = ("일반: \(data["여성용-대변기수"] == "" ? "정보없음" : data["여성용-대변기수"]!) / 장애인용: \(data["여성용-장애인용대변기수"] == "" ? "정보없음" : data["여성용-장애인용대변기수"]!)")
        useButton.setTitle(UserDefaults.standard.string(forKey: "useButtonTitle"), for: .normal)
        latitudeAndLongitude = "\(data["위도"]!), \(data["경도"]!)"
        emergencyBellValue.text = (data["비상벨설치여부"] == "Y" ? "비상벨 O" + (data["비상벨설치장소"] == "" ? "" : " (위치: \(data["비상벨설치장소"] ?? ""))") : "비상벨 X")
        emergencyBellValue.attributedText = changeTextColor(text: emergencyBellValue.text ?? "")
        cctvValue.text = data["화장실입구CCTV설치유무"] == "Y" ? "입구 앞 CCTV O" : "입구 앞 CCTV X"
        cctvValue.attributedText = changeTextColor(text: cctvValue.text ?? "")
        diaperValue.text = (data["기저귀교환대유무"] == "Y" ? "기저귀교환대 O" + (data["비상벨설치장소"] == "" ? "" : " (위치: \(data["기저귀교환대장소"] ?? ""))") : "기저귀교환대 X")
        diaperValue.numberOfLines = 2
        diaperValue.attributedText = changeTextColor(text: diaperValue.text ?? "")
        if data["전화번호"] == "" {
            callButton.tintColor = .secondarySystemBackground
        } else {
            callButton.tintColor = UIColor(red: 0, green: 178/255, blue: 167/255, alpha: 1)
            callNumber = data["전화번호"]!
            let tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(calling(_ :)))
            callButton.addGestureRecognizer(tapGesture)
        }
    }
    
    func changeTextColor(text: String) -> NSMutableAttributedString {
        let attributedStr = NSMutableAttributedString(string: text)
//        attributedStr.addAttribute(.foregroundColor, value: UIColor(red: 136/255, green: 250/255, blue: 78/255, alpha: 1), range: (text as NSString).range(of: "O"))
        attributedStr.addAttribute(.foregroundColor, value: UIColor(red: 97/255, green: 216/255, blue: 54/255, alpha: 1), range: (text as NSString).range(of: "O"))
        attributedStr.addAttribute(.foregroundColor, value: UIColor(red: 1, green: 100/255, blue: 78/255, alpha: 1), range: (text as NSString).range(of: "X"))
        return attributedStr
    }
    
    func changeTextSize(text: String) -> NSMutableAttributedString {
        let font: UIFont = UIFont(name: "Avenir Book", size: 15)!
        let attributedStr = NSMutableAttributedString(string: text)
        attributedStr.addAttribute(.font, value: font, range: (text as NSString).range(of: "✅"))
        attributedStr.addAttribute(.font, value: font, range: (text as NSString).range(of: "❌"))
        return attributedStr
    }
}

extension CardViewController: MFMessageComposeViewControllerDelegate {
//    func timerMeasurementsInBackground() {
//        if useButton.currentTitle == "위험대비문자 발송" {
//
//            useButton.setTitle("안심문자 발송", for: .normal)
//            useButton.backgroundColor = UIColor(red: 74/255, green: 166/255, blue: 157/255, alpha: 1)
//            if let timer = secondTimer {
//                if !timer.isValid {
//                    secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCallback), userInfo: nil, repeats: true)
//                    RunLoop.current.add(secondTimer!, forMode: .common)
//                }
//            } else {
//                secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCallback), userInfo: nil, repeats: true)
//                RunLoop.current.add(secondTimer!, forMode: .common)
//            }
//        } else if useButton.currentTitle == "안심문자 발송"{
//            useButton.setTitle("위험대비문자 발송", for: .normal)
//            useButton.backgroundColor = UIColor(red: 254/255, green: 115/255, blue: 111/255, alpha: 1)
//            if let timer = secondTimer {
//                if timer.isValid {
//                    timer.invalidate()
//                }
//            }
//            number = 0
//        }
//        print(useButton.currentTitle!)
//        UserDefaults.standard.set(useButton.currentTitle!, forKey: "useButtonTitle")
//    }

    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            NotificationCenter.default.post(name: NSNotification.Name("sendMessage"), object: true)
            UserDefaults.standard.set(true, forKey: "sentHelpMessage")
            dismiss(animated: true, completion: nil)
//            if CLLocationManager.locationServicesEnabled() {
//                switch CLLocationManager.authorizationStatus() {
//                case .authorizedAlways:
//                    timerMeasurementsInBackground()
//                default:
//                    useButton.setTitle("위험대비문자 발송", for: .normal)
//                    useButton.backgroundColor = .urgent
//                    gpsState = .off
//                }
//            }
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
        completionHandler([.sound, .badge, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        self.present(settingsViewController, animated: true, completion: nil)
    }
}
