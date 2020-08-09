//
//  GetContactsManager.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/26/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import Contacts
import SwiftUI

class ContactStore: ObservableObject {
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil

    func fetch() {
        print("Fetching contacts")
        do {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                               CNContactMiddleNameKey as CNKeyDescriptor,
                               CNContactFamilyNameKey as CNKeyDescriptor,
                               CNContactImageDataAvailableKey as CNKeyDescriptor,
                               CNContactThumbnailImageDataKey as CNKeyDescriptor,
                               CNContactImageDataKey as CNKeyDescriptor,
                               CNContactPhoneNumbersKey as CNKeyDescriptor,
                               CNContactPostalAddressesKey as CNKeyDescriptor
                                ]
            print("Fetching contacts: now")
            let containerId = store.defaultContainerIdentifier()
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            print("Fetching contacts: succesfull with count = \(contacts.count)")

            var phoneNumers: [String] = []
            for contact in contacts {
                for phone in contact.phoneNumbers {
                    if let label = phone.label {
                        if label == CNLabelPhoneNumberMobile {
                            var number = phone.value.stringValue
                            number = format(with: "+1XXXXXXXXXX", phone: number)
                            print(number)
                            phoneNumers.append(number)
                        }
                    }
                }
            }
            
            WebService.checkPhoneNumbers(phoneNumbers: phoneNumers) { retunredNumbers in
                
                for number in retunredNumbers.invitablePhoneNumbers {
                    print(number)
                }
            
                DispatchQueue.main.async {
                    self.contacts = contacts
                }
            }
            
        } catch {
            print("Fetching contacts: failed with %@", error.localizedDescription)
            self.error = error
        }
    }
    
    func checkForHome() {
        
        for contact in contacts {
            if contact.postalAddresses.count > 0 {
                
            }
        }
    }
}
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }

