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
    var filteredContacts = [ContactStruct]()
    var contactStore = CNContactStore()
    var contacts = [ContactStruct]()
    var emergencyViewController: EmergencyViewController!
    
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
        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContacts.count
        }
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
        let contactToDisplay: ContactStruct
        if isFiltering(){
            contactToDisplay = filteredContacts[indexPath.row]
        } else {
            contactToDisplay = contacts[indexPath.row]
        }
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
            
            let contactToAppend = ContactStruct(givenName: name, familyName: familyName, number: number ?? "")
            self.contacts.append(contactToAppend)
        })
        tableView.reloadData()
//        print(contacts.first?.givenName)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popToRootViewController(animated: true)
        var currentContact: [String:String] = [:]
        if isFiltering() {
            currentContact["name"] = filteredContacts[indexPath.row].givenName + " " + filteredContacts[indexPath.row].familyName
            currentContact["phone"] = filteredContacts[indexPath.row].number
        } else {
            currentContact["name"] = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
            currentContact["phone"] = contacts[indexPath.row].number
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
