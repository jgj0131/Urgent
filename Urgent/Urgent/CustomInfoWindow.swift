//
//  CustomInfoWindow.swift
//  Urgent
//
//  Created by jang gukjin on 24/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var snippet: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    override init(frame: CGRect) {
     super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
    }
    
    func loadView() -> CustomInfoWindow{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        return customInfoWindow
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
