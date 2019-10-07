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
    
    let searchController = UISearchController(searchResultsController: nil)
    private var filteredContacts = [ContactStruct]()
    private var contactStore = CNContactStore()
    private var contacts = [ContactStruct]()
    private var emergencyViewController: EmergencyViewController!
    private var contactsDictionary = [String:[ContactStruct]]()
    private var contactSectionTitles = [String]()
    
    //let request = CNContactFetchRequest(keysToFetch: keys)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "name"
        if #available(iOS 13.0, *) {
            searchController.searchBar.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        contactStore.requestAccess(for: .contacts, completionHandler: { (success, error) in
            if success {
                print("연락처 불러오기 성공")
            }
        })
        fetchContacts()
        contacts.sort()
        
        for contact in contacts {
            let contactName = contact.familyName == "" ? contact.givenName : contact.familyName + " " + contact.givenName
            let contactKey = prefixKorean(name: contactName)//String(contactName.prefix(1))
                   if var contactValues = contactsDictionary[contactKey] {
                       contactValues.append(contact)
                       contactsDictionary[contactKey] = contactValues
                   } else {
                       contactsDictionary[contactKey] = [contact]
                   }
               }

               contactSectionTitles = [String](contactsDictionary.keys)
               contactSectionTitles = contactSectionTitles.sorted(by: { $0 < $1 })
        tableView.reloadData()
    }
    
    /// 이름을 받아 한글인 경우 맨 앞글자의 초성을 따오는 메소드
    func prefixKorean(name:String) -> String {
        guard let firstText = name.first else { return "" }
        let unicodeText = Unicode.Scalar(String(firstText))?.value
        guard let value = unicodeText else { return "" }
        if (value < 0xAC00 || value > 0xD7A3) { return String(name.prefix(1)) }
        else {
            let first = ((value - 0xAC00)/28)/21
            if let scalarValue = Unicode.Scalar(0x1100 + first) {
                return String(scalarValue)
            } else {
                return ""
            }
        }
    }
    
    /// 초성을 기준으로 section 명들을 저장하는 배열을 생성하고, sectionIndexTitles을 정의하는 메소드
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactSectionTitles
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
      filteredContacts = contacts.filter({( contact : ContactStruct) -> Bool in
        return contact.givenName.lowercased().contains(searchText.lowercased()) || contact.familyName.lowercased().contains(searchText.lowercased())
      })

      tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering(){
            return 1
        } else {
            return contactSectionTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContacts.count
        } else {
            let contactKey = contactSectionTitles[section]
            if let contactValues = contactsDictionary[contactKey] {
                return contactValues.count
            }
            return 0
        }
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
        let contactToDisplay: ContactStruct
        if isFiltering(){
            contactToDisplay = filteredContacts[indexPath.row]
            cell.textLabel?.text = contactToDisplay.familyName + " " + contactToDisplay.givenName
            cell.detailTextLabel?.text = contactToDisplay.number
        } else {
            let contactKey = contactSectionTitles[indexPath.section]
            if let contactValues = contactsDictionary[contactKey] {
                cell.textLabel?.text = contactValues[indexPath.row].familyName + " " + contactValues[indexPath.row].givenName
                cell.detailTextLabel?.text = contactValues[indexPath.row].number
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactSectionTitles[section]
    }
    
    func fetchContacts() {
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        try! contactStore.enumerateContacts(with: request, usingBlock: {(contact, stoppingPointer) in
            let name = contact.givenName
            let familyName = contact.familyName
            let number = contact.phoneNumbers.first?.value.stringValue
            
            let contactToAppend = ContactStruct(givenName: name, familyName: familyName, number: number ?? "")
            self.contacts.append(contactToAppend)
        })
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popToRootViewController(animated: true)
        var currentContact: [String:String] = [:]
        if isFiltering() {
            currentContact["name"] = filteredContacts[indexPath.row].familyName + " " + filteredContacts[indexPath.row].givenName
            currentContact["phone"] = filteredContacts[indexPath.row].number
        } else {
            currentContact["name"] = (contactsDictionary[contactSectionTitles[indexPath.section]]?[indexPath.row].familyName)! + " " + (contactsDictionary[contactSectionTitles[indexPath.section]]?[indexPath.row].givenName)! //contacts[indexPath.row].givenName + "" + contacts[indexPath.row].familyName
            currentContact["phone"] = (contactsDictionary[contactSectionTitles[indexPath.section]]?[indexPath.row].number)!//contacts[indexPath.row].number
        }
        
        emergencyViewController = EmergencyViewController(nibName: "EmergencyViewController", bundle: nil)
        emergencyViewController.addContact(data: currentContact)
    }
}

extension CallContactViewCellViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
