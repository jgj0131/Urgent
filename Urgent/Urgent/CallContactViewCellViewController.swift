//
//  CallContactViewCellViewController.swift
//  Urgent
//
//  Created by jang gukjin on 09/09/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit
import Contacts

class CallContactViewCellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var contactStore = CNContactStore()
    var contacts = [ContactStruct]()
    var emergencyViewController: EmergencyViewController!
    
    //let request = CNContactFetchRequest(keysToFetch: keys)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        contactStore.requestAccess(for: .contacts, completionHandler: { (success, error) in
            if success {
                print("연락처 불러오기 성공")
            }
        })
        fetchContacts()
        contacts.sort()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("click")
        if let phoneCallURL = URL(string: "tel://\(contacts[indexPath.row].number)") {
            let application: UIApplication = UIApplication.shared
            if(application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let contactToDisplay = contacts[indexPath.row]
        cell.textLabel?.text = contactToDisplay.givenName + " " + contactToDisplay.familyName
        cell.detailTextLabel?.text = contactToDisplay.number
        return cell
    }
    
    func fetchContacts() {
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        try! contactStore.enumerateContacts(with: request, usingBlock: {(contact, stoppingPointer) in
            let name = contact.givenName
            let familyName = contact.familyName
            let number = contact.phoneNumbers.first?.value.stringValue
            
            let contactToAppend = ContactStruct(givenName: name, familyName: familyName, number: number!)
            self.contacts.append(contactToAppend)
        })
        tableView.reloadData()
//        print(contacts.first?.givenName)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popToRootViewController(animated: true)
        var currentContact: [String:String] = [:]
        currentContact["name"] = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
        currentContact["phone"] = contacts[indexPath.row].number
        emergencyViewController = EmergencyViewController(nibName: "EmergencyViewController", bundle: nil)
        emergencyViewController.addContact(data: currentContact)
    }
}

