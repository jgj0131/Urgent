//
//  OnOffTableViewCell.swift
//  Urgent
//
//  Created by jang gukjin on 10/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class OnOffTableViewCell: UITableViewCell {
    
    @IBOutlet weak var onOffLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        onOffSwitch.onTintColor = .urgent
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
