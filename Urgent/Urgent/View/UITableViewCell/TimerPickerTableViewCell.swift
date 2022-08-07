//
//  TimerPickerTableViewCell.swift
//  Urgent
//
//  Created by jang gukjin on 17/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class TimerPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var timerPicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
