//
//  SampleTableViewCell.swift
//  Urgent
//
//  Created by jang gukjin on 10/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class SampleTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navi: UINavigationBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserContacts") as! UserContactsTableViewCell
        cell.name.text = "Aiden"//contacts[indexPath.row - 1]["name"]
        cell.phone.text = "010-5159-2661"//contacts[indexPath.row - 1]["phone"]
        return cell
    }
}
