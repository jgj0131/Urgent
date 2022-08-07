//
//  UserContactsTableViewCell.swift
//  Urgent
//
//  Created by jang gukjin on 09/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class UserContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func output(data: [String:String]) {
//        name.text = data["name"]!
//        
//    }
}
