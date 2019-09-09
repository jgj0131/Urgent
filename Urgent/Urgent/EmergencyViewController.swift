//
//  EmergencyViewController.swift
//  Urgent
//
//  Created by jang gukjin on 04/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

var contacts: [[String:String]] = []
var contactAppend: Bool = false

class EmergencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: IBActions
    @IBAction func closeEmergency(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editRows(_ sender: UIButton) {
        if tableView.isEditing {
            sender.titleLabel?.text = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            sender.titleLabel?.text = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    //var userContacts : UserContactsTableViewCell!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nibName = UINib(nibName: "UserContactsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "UserContacts")
    }

    override func viewDidAppear(_ animated: Bool) {
//        tableView.reloadData()
        if contactAppend == true {
            let indexPath = IndexPath(row: contacts.count, section: 2)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            tableView.endUpdates()
            contactAppend = false
        }
    }
    
    // MARK: Custom Methods
    func addContact(data: [String:String]) {
        if !contacts.contains(data) {
            contacts.append(data)
            contactAppend = true
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return contacts.count + 1
        default:
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "비상연락"
        case 1:
            return "시간설정"
        default:
            return "비상연락처"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OnOff") as! UITableViewCell
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSetting") as! UITableViewCell
            cell.selectionStyle = .none
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Contact") as! ContactTableViewCell
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserContacts") as! UserContactsTableViewCell
                cell.name.text = contacts[indexPath.row - 1]["name"]
                cell.phone.text = contacts[indexPath.row - 1]["phone"]
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section < 2 || indexPath.row < 1 {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2, indexPath.row > 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete, indexPath.section == 2, indexPath.row > 0 {
            contacts.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
