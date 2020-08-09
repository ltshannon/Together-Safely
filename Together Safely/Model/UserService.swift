//
//  UserService.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/27/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Contacts

class FirebaseService: ObservableObject {
    @Published var phoneNumber:String = "XXXXXXX"
    @Published var riskScore: Int = 0
    @Published var user: User = User(snapshot: [:])
    @Published var groups: [Groups] = []
    @Published var riskRanges: [[String:RiskHighLow]] = []
    @Published var invites: [Invite] = []
    @Published var userContacts: [TogetherContactType] = []
    @Published var contactGroups: [Groups] = []
    @Published var contactInfo: [[String:ContactInfo]] = []
    

    static let shared = FirebaseService()
    private var database = Firestore.firestore()
    private var groupsArray: [Groups] = []
    private var userName: String = ""
    private var userImage: Data?

    init() {}
    
    func checkUser(byPhoneNumber phoneNumber: String, completion: @escaping (Int, Error?) -> Void) {
        self.database.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(0, err)
            } else {
                if querySnapshot!.documents.count == 1 {
                    let doc = querySnapshot!.documents[0]
                    let riskScore = (doc.data()["riskScore"] as? Int) ?? 99999
                    completion(riskScore, nil)
                }
            }
            completion(0, nil)
        }
    }
    
    func getServerData(byPhoneNumber: String) {
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
            let containerId = store.defaultContainerIdentifier()
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            print("Fetching contacts: succesfull with count = %d", contacts.count)

            var phoneNumbers: [String] = []
            print("Numbers returned for contacts call:")
            let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
            var cinfo: [[String:ContactInfo]] = []
            for contact in contacts {
                for phone in contact.phoneNumbers {
                    if let label = phone.label {
                        if label == CNLabelPhoneNumberMobile {
                            var number = phone.value.stringValue
                            number = format(with: "+1XXXXXXXXXX", phone: number)
                            print(number)
                            let c: ContactInfo = ContactInfo(
                                image: contact.imageData,
                                name: "\(contact.givenName) " + "\(contact.familyName)"
                            )
         
                            cinfo.append([number:c])
                            if number.contains(userPhoneNumber) {
                                userName = "\(contact.givenName) " + "\(contact.familyName)"
                                if let imageData = contact.imageData {
                                    userImage = imageData
                                }
                            }
                            phoneNumbers.append(number)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.contactInfo = cinfo
            }
             
            WebService.checkPhoneNumbers(phoneNumbers: phoneNumbers) { returnedNumbers in
                
                for number in returnedNumbers.invitablePhoneNumbers {
                    print("invitablePhoneNumbers: \(number)")
                }
                
                for number in returnedNumbers.invitedPhoneNumbers {
                    print("invitedPhoneNumbers: \(number)")
                }
                
                for number in returnedNumbers.userPhoneNumbers {
                    print("userPhoneNumbers: \(number)")
                }
                
                var userContacts: [TogetherContactType] = []
             
                for contact in contacts {
                    for phone in contact.phoneNumbers {
                        if let label = phone.label {
                            if label == CNLabelPhoneNumberMobile {
                                var number = phone.value.stringValue
                                number = format(with: "+1XXXXXXXXXX", phone: number)
                                if returnedNumbers.invitablePhoneNumbers.contains(number) {
                                    let c = TogetherContactType(contactInfo: contact, type: .invitablePhoneNumber, phoneNumber: number, riskScore: nil, riskString: nil)
                                    userContacts.append(c)
                                } else if returnedNumbers.invitedPhoneNumbers.contains(number) {
                                    let c = TogetherContactType(contactInfo: contact, type: .invitedPhoneNumber, phoneNumber: number, riskScore: nil, riskString: nil)
                                    userContacts.append(c)
                                } else {
                                    let c = TogetherContactType(contactInfo: contact, type: .userPhoneNumber, phoneNumber: number, riskScore: nil, riskString: nil)
                                    userContacts.append(c)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.userContacts = userContacts
                }
                if self.riskRanges.count > 0 {
                    for (index, contact) in self.userContacts.enumerated() {
                        if contact.type == .userPhoneNumber {
                            self.checkUser(byPhoneNumber: contact.phoneNumber) { (score, error) in
                                if let error = error {
                                    print("firebase couldn't find user: \(contact.phoneNumber) with error: \(error.localizedDescription)")
                                } else {
                                    self.userContacts[index].riskScore = score
                                    self.userContacts[index].riskString = self.getRiskString(value: score)
                                    DispatchQueue.main.async {
                                        self.userContacts = self.userContacts
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.getUserData(phoneNumber: byPhoneNumber)
            }
             
        } catch {
            print("Fetching contacts: failed with %@", error.localizedDescription)
        }
    }


    func getUserData(phoneNumber: String) {
        if riskRanges.count == 0 {
            getRiskRanges{ error in
                guard error == nil else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
                for (index, contact) in self.userContacts.enumerated() {
                    if contact.type == .userPhoneNumber {
                        self.checkUser(byPhoneNumber: contact.phoneNumber) { (score, error) in
                            if let error = error {
                                print("firebase couldn't find user: \(contact.phoneNumber) with error: \(error.localizedDescription)")
                            } else {
                                self.userContacts[index].riskScore = score
                                self.userContacts[index].riskString = self.getRiskString(value: score)
                                DispatchQueue.main.async {
                                    self.userContacts = self.userContacts
                                }
                            }
                        }
                    }
                }
                self.getUserData(phoneNumber: phoneNumber) { error in
                        guard error == nil else {
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            return
                        }
                    return
                }
            }
            return
        }
        getUserData(phoneNumber: phoneNumber) { error in
                guard error == nil else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
        }
    }
    
    func getRiskFactorQuestions(_ completion: @escaping ([UserQuestion]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion([UserQuestion]())
            return
        }
        database.collection("users").document(currentUser.uid).getDocument { [weak self] (userSnapshot, error) in
            guard let self = self, let userData = userSnapshot?.data(), error == nil else {
                completion([UserQuestion]())
                return
            }
            let user = User(snapshot: userData)
            self.database.collection("userQuestions").getDocuments { (questionsSnapshot, error) in
                guard let questionsSnapshot = questionsSnapshot?.documents, error == nil else {
                    completion([UserQuestion]())
                    return
                }
                let questions = questionsSnapshot.compactMap { questionSnapshot -> UserQuestion? in
                    do {
                        var retval = try questionSnapshot.data(as: UserQuestion.self)
                        retval?.userResponse = user.userAnswers.first(where: { (userAnswer) -> Bool in
                            return userAnswer.userQuestion == questionSnapshot.documentID
                        })?.answer
                        
                        return retval
                    } catch let err {
                        print(err.localizedDescription)
                        return nil
                    }
                }
                let orderedQuestions = questions.sorted { (q1, q2) -> Bool in
                    return q1.order < q2.order
                }
                completion(orderedQuestions)
            }
        }
    }
    
    func getUserData(phoneNumber: String, completion: @escaping (Error?) -> Void) {
    
        self.database.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    completion(error)
                    return
                }
                if documents.count == 1 {
                    let doc = querySnapshot!.documents[0]
                    var user = User(snapshot: doc.data())
                    user.riskString = self.getRiskString(value: user.riskScore)
                    user.name = self.userName
                    user.image = self.userImage

                    DispatchQueue.main.async {
                        self.user = user
                    }
                    
                    var invites: [Invite] = []
                    for invite in user.groupInvites {
                        let docRef = self.database.collection("groups").document(invite)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let group = Groups(snapshot: document.data() ?? [:])
                                var invite:Invite = Invite(adminName: "", groupName: group.name, groupId: invite, riskScore: 99999)
                                let docRef2 = self.database.collection("users").document(group.id)
                                    docRef2.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            let user = User(snapshot: document.data() ?? [:])
                                            invite.riskScore = user.riskScore
                                            invites.append(invite)
                                            DispatchQueue.main.async {
                                                self.invites = invites
                                            }
                                        } else {
                                            print("User document not found look for group admin: \(error!)")
                                        }
                                    }
                            } else {
                                print("Group document not found: \(error!)")
                            }
                        }
                    }
                    
                    for group in user.groups {
                        self.database.collection("groups").document(group)
                            .addSnapshotListener { documentSnapshot, error in
                            guard let document = documentSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            var groups = Groups(snapshot: document.data() ?? [:])
                            var dict: [String : Int] = [:]
                            var groupAverageRisk: Int = 0

                            for (index, member) in groups.members.enumerated() {
                                groups.members[index].riskString = self.getRiskString(value: member.riskScore)
                                if let total = dict[groups.members[index].riskString] {
                                    dict[groups.members[index].riskString] = total + 1
                                }
                                else {
                                    dict[groups.members[index].riskString] = 1
                                }
                                groupAverageRisk += member.riskScore
                            }
                                
                            if groups.members.count > 0 {
                                let average = groupAverageRisk / groups.members.count
                                groups.averageRisk = self.getRiskString(value: average)
                                groups.averageRiskValue = average
                            }
                                
                            groups.riskTotals = dict
                                
                            let sortedByValueDictionary = dict.sorted { $0.1 > $1.1 }
                                
                            for dict in sortedByValueDictionary {
                                groups.riskCompiledSring.append(dict.key)
                                groups.riskCompiledValue.append(dict.value)
                            }
                            groups.id = document.documentID
                            for (index, _) in self.groupsArray.enumerated() {
                                if self.groupsArray[index].id == document.documentID {
                                    self.groupsArray.remove(at: index)
                                    break
                                }
                            }
                            self.groupsArray.append(groups)
                            DispatchQueue.main.async {
                                self.groups = self.groupsArray
                            }
                        }
                    }
                    completion(nil)
                }
        }
    }
    
    func getRiskRanges(completion: @escaping (Error?) -> Void) {
        
        database.collection("riskRanges").getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(err)
            } else {
                var dictionary: [[String:RiskHighLow]] = [[:]]
                for document in querySnapshot!.documents {
                    let riskRange = RiskHighLow(snapshot: document.data())
                    var s = [String: RiskHighLow]()
                    s[document.documentID] = riskRange
                    dictionary.append(s)
                }
                print(dictionary)
                self.riskRanges.removeAll()
                DispatchQueue.main.async {
                    self.riskRanges = dictionary
                }
                completion(nil)
            }
        }
    }
    
    func getRiskString(value: Int) -> String {
        
        for riskRange in self.riskRanges {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if value >= min && value <= max {
                    for key in riskRange.keys {
                        return key
                    }
                }
            }
        }
        
        return "N/A"
    }
    

}
