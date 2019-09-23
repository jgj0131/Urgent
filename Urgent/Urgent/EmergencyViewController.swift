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
var onOffStatus: Bool = true
var timerData: Double = 1800.0

class EmergencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Properties
    var dataPickerIndexPath: IndexPath?
    var cellHeight: CGFloat?
    
    
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
    
//    @IBAction func OnOff(_ sender: UISwitch) {
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
    //var userContacts : UserContactsTableViewCell!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onOffStatus = UserDefaults.standard.bool(forKey: "OnOffSwitch")
        timerData = UserDefaults.standard.double(forKey: "Timer")
        contacts = UserDefaults.standard.object(forKey: "Contacts") as? [[String : String]] ?? [[String:String]]()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let onOffNibName = UINib(nibName: "OnOffTableViewCell", bundle: nil)
        tableView.register(onOffNibName, forCellReuseIdentifier: "OnOff")
        let userContactsNibName = UINib(nibName: "UserContactsTableViewCell", bundle: nil)
        tableView.register(userContactsNibName, forCellReuseIdentifier: "UserContacts")
        let timeSettingNibName = UINib(nibName: "TimeSettingTableViewCell", bundle: nil)
        tableView.register(timeSettingNibName, forCellReuseIdentifier: "TimeSetting")
        let timerPickerNibName = UINib(nibName: "TimerPickerTableViewCell", bundle: nil)
        tableView.register(timerPickerNibName, forCellReuseIdentifier: "TimerPicker")
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
    
    // MARK: Objc Methods
    /// Switch의 상태가 변할 때 tableView를 reload하는 메소드
    @objc
    func onOffSwitching(sender : UISwitch){
        //        tableView.beginUpdates()
        //        tableView.endUpdates()
        onOffStatus = !onOffStatus
        //        if sender.isOn {
        //            tableView.deleteSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
        //        } else {
        ////            tableView.insertSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
        ////            tableView.reloadData()
        //        }
//        tableView.reloadData()
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: tableView.reloadData, completion: nil)
//        tableView.beginUpdates()
//        tableView.deleteSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
//        tableView.endUpdates()
        print(onOffStatus)
        UserDefaults.standard.set(sender.isOn, forKey: "OnOffSwitch")
    }
    
    /// Date Picker의 값이 변할 때 1 section 0 row의 label을 수정하는 메소드
    @objc
    func changed(sender: UIDatePicker) {
        timerData = sender.countDownDuration
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        UserDefaults.standard.set(timerData, forKey: "Timer")
    }
    
    // MARK: Custom Methods
    func addContact(data: [String:String]) {
        if !contacts.contains(data) {
            contacts.append(data)
            contactAppend = true
        }
    }

    /// section 별 row를 정의하는 메소드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            if dataPickerIndexPath != nil {
                return 2
            } else {
                return 1
            }
        case 2:
            return contacts.count + 1
        default:
            return 1
        }
    }
    
    /// OnOff의 상태에 따라 section의 개수를 정하는 메소드
    func numberOfSections(in tableView: UITableView) -> Int {
        if onOffStatus == true {
            return 3
        } else {
            return 1
        }
    }
    
    /// section 별 제목을 붙이는 메소드
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

    /// 각 cell들을 정의하는 메소드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OnOff") as! OnOffTableViewCell
            cell.onOffLabel.text = "활성화"
            cell.onOffSwitch.isOn = onOffStatus
            cell.onOffSwitch.addTarget(self, action: #selector(self.onOffSwitching(sender:)), for: .valueChanged)
            cell.selectionStyle = .none
            cellHeight = cell.frame.height
            return cell
        } else if indexPath.section == 1 {
            if dataPickerIndexPath == indexPath {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimerPicker") as! TimerPickerTableViewCell
                cell.timerPicker.datePickerMode = .countDownTimer
                cell.timerPicker.countDownDuration = timerData
                cell.timerPicker.addTarget(self, action: #selector(self.changed(sender:)), for: .valueChanged)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSetting") as! TimeSettingTableViewCell
                cell.timeTitle.text = "설정된 시간"
                cell.setTime.text = "\(Int(timerData) / 3600)시간 \((Int(timerData) % 3600) / 60)분"
                cell.selectionStyle = .default
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Contact") as! ContactTableViewCell
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserContacts") as! UserContactsTableViewCell
                cell.name.text = contacts[indexPath.row - 1]["name"]
                cell.phone.text = contacts[indexPath.row - 1]["phone"]
                UserDefaults.standard.set(contacts, forKey: "Contacts")
                return cell
            }
        }
    }
    
    /// cell의 높이를 지정하는 메소드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1, indexPath.row == 1 {
            return cellHeight! * 4
        } else {
            return cellHeight!
        }
    }
    
    /// 1 section이 선택되었을 때 Date Picker를 삽입하거나 삭제하는 메소드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
//        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1, let dataPickerIndexPath = dataPickerIndexPath, dataPickerIndexPath.row - 1 == indexPath.row{
            tableView.deleteRows(at: [dataPickerIndexPath], with: .fade)
            self.dataPickerIndexPath = nil
        } else {
            if let dataPickerIndexPath = dataPickerIndexPath {
                tableView.deleteRows(at: [dataPickerIndexPath], with: .fade)
            }
            dataPickerIndexPath = indexPathToInsertDataPicker(indexPath: indexPath)
            tableView.insertRows(at: [dataPickerIndexPath!], with: .fade)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
//        if indexPath.section == 1, indexPath.row == 0 {
//            print("생성")
//            tableView.insertRows(at: [indexPath], with: .fade)
//        } else {
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
    }
    
    /// Date Picker의 삽입을 위해 indexPath를 수정하는 함수
    func indexPathToInsertDataPicker(indexPath: IndexPath) -> IndexPath {
        if let dataPickerIndexPath = dataPickerIndexPath, dataPickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
//    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
//        if indexPath!.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "OnOff") as! OnOffTableViewCell
//            if !cell.onOffSwitch.isOn {
//                print("yes")
//                tableView.beginUpdates()
//                tableView.deleteSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
//                tableView.endUpdates()
//            } else {
//                print("No")
//            }
//        }
//    }
    /// 2 section의 cell들을 Edit하는 메소드
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 2, indexPath.row > 0 {
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    /// Edit 할 수 있는 cell들에 대한 조건을 정의하는 메소드
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2, indexPath.row > 0 {
            return true
        } else {
            return false
        }
    }
    
    /// Edit Style을 정의하는 메소드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete, indexPath.section == 2, indexPath.row > 0 {
            contacts.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            UserDefaults.standard.set(contacts, forKey: "Contacts")
        }
    }

    /// row를 변경할 수 있도록 하는 메소드
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
