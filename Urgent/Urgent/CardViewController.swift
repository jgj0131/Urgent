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
    
    // MARK: LifeCyvle
    override func viewDidLoad() {
        super.viewDidLoad()
        useButton.roundedCorner()
        
    }
    
    // MARK: Custom Method
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "Sub View" {
    //            let viewController = segue.destination as! ViewController
    //            viewController.dataDelegate = self
    //        }
    //    }
    
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
        restroomAddress.text = data["소재지변주소"] == "" ? "정보없음" : data["소재지지번주소"]!
        publicManAndWoman.text = data["남녀공용화장실여부"] == "" ? "정보없음" : data["남녀공용화장실여부"]!
        openingTime.text = data["개방시간"] == "" ? "정보없음" : data["개방시간"]!
        manToiletCount.text = data["남성용-대변기수"] == "" ? "정보없음" : data["남성용-대변기수"]!
        disabledManToiletCount.text = data["남성용-장애인용대변기수"] == "" ? "정보없음" : data["남성용-장애인용대변기수"]!
        womanToiletCount.text = data["여성용-대변기수"] == "" ? "정보없음" : data["여성용-대변기수"]!
        disabledWomanToiletCount.text = data["여성용-장애인용대변기수"] == "" ? "정보없음" : data["여성용-장애인용대변기수"]!
    }
}
