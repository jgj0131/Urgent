//
//  CardViewController.swift
//  Urgent
//
//  Created by jang gukjin on 16/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
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
        if sender.currentTitle == "사용하기" {
            sender.setTitle("사용완료", for: .normal)
        } else {
            sender.setTitle("사용하기", for: .normal)
        }
    }
    
    // MARK: LifeCyvle
    override func viewDidLoad() {
        self.backgroundArea.layer.cornerRadius = 15
        self.handleArea.layer.cornerRadius = 15
        
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
    
    // View가 Load 되었을 때 데이터들을 불러오는 메소드
    func output(data: [String:String]) {
        print(isViewLoaded)
        guard self.isViewLoaded == true else {
            return
        }
        sendData(data: data)
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
        manToiletCount.text = data["남성용-대변기수"] == "" ? "정보없음" : data["남성용-대변기수"]!
        disabledManToiletCount.text = data["남성용-장애인용대변기수"] == "" ? "정보없음" : data["남성용-장애인용대변기수"]!
        womanToiletCount.text = data["여성용-대변기수"] == "" ? "정보없음" : data["여성용-대변기수"]!
        disabledWomanToiletCount.text = data["여성용-장애인용대변기수"] == "" ? "정보없음" : data["여성용-장애인용대변기수"]!
        useButton.setTitle("사용하기", for: .normal)
    }
}
