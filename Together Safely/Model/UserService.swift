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
    @Published var riskColors: [[String:String]] = []
    @Published var invites: [Invite] = []
    @Published var userContacts: [TogetherContactType] = []
    @Published var contactGroups: [Groups] = []
    @Published var contactInfo: [[String:ContactInfo]] = []
    @Published var userContantRiskAverageString = ""
    @Published var userContantRiskAverageValue = 0.0
    @Published var userContantRiskAverageDict: [String : Int] = [:]
    @Published var userContantUsersCount = 0

    static let shared = FirebaseService()
    private var database = Firestore.firestore()
    private var groupsArray: [Groups] = []
    private var invitesArray: [Invite] = []
    private var userName: String = ""
    private var userImage: Data?
    private var allUsers: [User] = []
    private var userListener: ListenerRegistration?
    private var groupListeners: [ListenerRegistration?] = []

    init() {
//        getServerData(byPhoneNumber: UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? "")
    }
    
    func checkUser(byPhoneNumber phoneNumber: String, completion: @escaping (Double, Error?) -> Void) {
        self.database.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(0, err)
            } else {
                if querySnapshot!.documents.count == 1 {
                    let doc = querySnapshot!.documents[0]
                    let riskScore = (doc.data()["riskScore"] as? Double) ?? 99999
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
            print("Fetching contacts: succesfull with count = \(contacts.count)")

            var phoneNumbers: [String] = []
            let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
            var cinfo: [[String:ContactInfo]] = []
            for contact in contacts {
                for phone in contact.phoneNumbers {
                    var number = phone.value.stringValue
                    number = number.deletingPrefix("+")
                    number = number.deletingPrefix("1")
                    number = format(with: "+1XXXXXXXXXX", phone: number)
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
            
            DispatchQueue.main.async {
                self.contactInfo = cinfo
            }
             
            WebService.checkPhoneNumbers(phoneNumbers: phoneNumbers) { returnedNumbers in
/*
                for number in returnedNumbers.invitablePhoneNumbers {
                    print("invitablePhoneNumbers: \(number)")
                }
                for number in returnedNumbers.invitedPhoneNumbers {
                    print("invitedPhoneNumbers: \(number)")
                }
                for number in returnedNumbers.userPhoneNumbers {
                    print("userPhoneNumbers: \(number)")
                }
*/
                var userContacts: [TogetherContactType] = []
             
                for contact in contacts {
                    for phone in contact.phoneNumbers {
                        var number = phone.value.stringValue
                        number = number.deletingPrefix("+")
                        number = number.deletingPrefix("1")
                        number = format(with: "+1XXXXXXXXXX", phone: number)
                        var c: TogetherContactType
                        if returnedNumbers.invitablePhoneNumbers.contains(number) {
                            c = TogetherContactType(name: contact.name, type: .invitablePhoneNumber, phoneNumber: number, riskScore: nil, riskString: nil)
                        } else if returnedNumbers.invitedPhoneNumbers.contains(number) {
                            c = TogetherContactType(name: contact.name, type: .invitedPhoneNumber, phoneNumber: number, riskScore: nil, riskString: nil)
                        } else {
                            c = TogetherContactType(name: contact.name, type: .userPhoneNumber, phoneNumber: number, riskScore: nil, riskString: nil)
                        }
                        userContacts.append(c)
                    }
                }
                
                userContacts.sort { return $0.type.sortOrder < $1.type.sortOrder }
                
                DispatchQueue.main.async {
                    self.userContacts = userContacts
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
                
                guard Auth.auth().currentUser != nil  else {
                    print("Could not auth user")
                    return
                }
                self.database.collection("users").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        // Should this be a fatal error?
                    }
                    for document in querySnapshot!.documents {
                        var user = User(snapshot: document.data())
                        user.id = document.documentID
                        self.allUsers.append(user)
                    }
                
                    var dict: [String : Int] = [:]
                    var userContactAverageRisk = 0.0
                    var userContactCount = 0.0

                    for (index, contact) in self.userContacts.enumerated() {
                        if contact.type == .userPhoneNumber {
                            let score = self.getRiskScoreForUser(phoneNumber: self.userContacts[index].phoneNumber)
                            self.userContacts[index].riskScore = score
 
                            let str = self.getRiskString(value: score)
                            self.userContacts[index].riskString = str
                            if let total = dict[str] {
                                dict[str] = total + 1
                            }
                            else {
                                dict[str] = 1
                            }
                            userContactAverageRisk += score
                            userContactCount += 1
                        }
                    }

                    DispatchQueue.main.async {
                        if userContactCount > 0 {
                            let average = userContactAverageRisk / userContactCount
                            self.userContantRiskAverageString = self.getRiskString(value: average)
                            self.userContantRiskAverageValue = average
                            self.userContantRiskAverageDict = dict
                            self.userContantUsersCount = Int(userContactCount)
                        }
                    }
                    
                    self.getUserData(phoneNumber: phoneNumber) { error in
                        guard error == nil else {
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            return
                        }
                    }
                }
            }
        } else {
            getUserData(phoneNumber: phoneNumber) { error in
                    guard error == nil else {
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        return
                    }
            }
        }
    }
    
    func getRiskScoreForUser(phoneNumber: String) -> Double {
        
        for user in allUsers {
            if user.phoneNumber == phoneNumber {
                return user.riskScore
            }
        }
        return 0
        
    }
    
    func getRiskQuestionGroups(_ completion: @escaping ([QuestionGroups]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion([QuestionGroups]())
            return
        }
        database.collection("users").document(currentUser.uid).getDocument { [weak self] (userSnapshot, error) in
            guard let self = self, let userData = userSnapshot?.data(), error == nil else {
                completion([QuestionGroups]())
                return
            }
            let user = User(snapshot: userData)
            self.database.collection("questionGroups").getDocuments { (groupsSnapshot, error) in
                guard let groupsSnapshot = groupsSnapshot?.documents, error == nil else {
                    completion([QuestionGroups]())
                    return
                }
                
                var questions: [QuestionGroups] = []
                for document in groupsSnapshot {
                    var question = QuestionGroups(snapshot: document.data(), groupID: document.documentID, answers: user.userGroupAnswers)
                    question.id = document.documentID
                    questions.append(question)
                }
                let orderedQuestions = questions.sorted { (q1, q2) -> Bool in
                    return q1.order < q2.order
                }
                completion(orderedQuestions)
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
    
    func getNameForPhone(_ phoneNumber: String, dict: [[String:ContactInfo]]) -> String {
        
        for d in dict {
            if d[phoneNumber] != nil {
                return(d[phoneNumber]!.name)
            }
        }
        return phoneNumber
    }
    
    func getUserData(phoneNumber: String, completion: @escaping (Error?) -> Void) {
    
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .medium
        var localDate = dateFormatter.string(from: Date())
        
        if let listener = self.userListener {
            print("Listener user being removed")
            listener.remove()
        }
        self.userListener = self.database.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: users")
                    completion(error)
                    return
                }
                
                localDate = dateFormatter.string(from: Date())
                print("Received Firebase data for users document: \(localDate)")
                if documents.count == 1 {
                    let doc = querySnapshot!.documents[0]
                    var user = User(snapshot: doc.data())
                    user.id = doc.documentID
                    user.riskString = self.getRiskString(value: user.riskScore)
                    user.name = self.userName
                    user.image = self.userImage

                    DispatchQueue.main.async {
                        self.user = user
                    }

                    querySnapshot!.documentChanges.forEach { diff in
                        print("User documentChanges: \(diff.document.data()) type: \(diff.type == .added ? "Add" : diff.type == .modified ? "Modified" :  diff.type == .removed ? "Removed" : "nothing")")
                        if (diff.type == .added || diff.type == .modified) {
                            print("Add or modified")
                            self.invitesArray.removeAll()
                            DispatchQueue.main.async {
                                self.invites = self.invitesArray
                            }
                            let item = GroupInvites(snapshot: diff.document.data())
                            for invite in item.groupInvites {
                                let docRef = self.database.collection("groups").document(invite)
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let group = Groups(snapshot: document.data() ?? [:])
                                        localDate = dateFormatter.string(from: Date())
                                        print("Firebase data for invite for group: \(invite) : \(localDate)")
                                        var invite:Invite = Invite(adminName: "", adminPhone: "", groupName: group.name, groupId: invite, riskScore: 99999)
                                        for user in self.allUsers {
                                            if user.id == group.adminId {
                                                invite.riskScore = user.riskScore
                                                invite.adminPhone = user.phoneNumber
                                                invite.adminName = user.name
                                                self.invitesArray.append(invite)
                                                DispatchQueue.main.async {
                                                    self.invites = self.invitesArray
                                                }
                                                break
                                            }
                                        }
                                    } else {
                                        print("Group document for group id: \(invite) not found")
                                    }
                                }
                            }
                        }
                        if (diff.type == .removed) {
                            print("Removed")
                            let item = GroupInvites(snapshot: diff.document.data())
                            for invite in item.groupInvites {
                                for (index, element) in self.invitesArray.enumerated() {
                                    if invite == element.groupId {
                                        self.invitesArray.remove(at: index)
                                    }
                                }
                            }
                        }
                    }

                    localDate = dateFormatter.string(from: Date())
                    for listener in self.groupListeners {
                        if let listen = listener {
                            print("Group listener being removed: \(localDate)")
                            listen.remove()
                        }
                    }
                    
                    self.groupListeners.removeAll()
                    localDate = dateFormatter.string(from: Date())
                    print("Received Firebase data for \(user.groups.count) groups at: \(localDate)")
                    for group in user.groups {
                        let groupListen = self.database.collection("groups").document(group)
                            .addSnapshotListener { documentSnapshot, error in
//                        let docRef = self.database.collection("groups").document(group)
//                        docRef.getDocument { (documentSnapshot, error) in
                            guard let document = documentSnapshot else {
                                print("Error fetching document")
                                return
                            }

                            localDate = dateFormatter.string(from: Date())
                            print("Received Firebase data for group document: \(group) at: \(localDate)")
                                
                            var groups = Groups(snapshot: document.data() ?? [:])
                                
                            print("")
                            var dict: [String : Int] = [:]
                            var groupAverageRisk = 0.0

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
                                let average = groupAverageRisk / Double(groups.members.count)
                                groups.averageRisk = self.getRiskString(value: average)
                                groups.averageRiskValue = average
                            }
                                
                            groups.riskTotals = dict
                                
                            let sortedByValueDictionary = dict.sorted { $0.1 > $1.1 }
                                
                            for dict in sortedByValueDictionary {
                                groups.riskCompiledSring.append(dict.key)
                                groups.riskCompiledValue.append(dict.value)
                            }
/*
                            print("document.documentID: \(document.documentID)")
                            print("groups.id: \(groups.id)")
                            print("groups.adminId: \(groups.adminId)")
                            if let userId = user.id {
                                print("user.id: \(userId)")
                            }
*/
                            var found = false
                            groups.id = document.documentID
                            for (index, _) in self.groupsArray.enumerated() {
                                if self.groupsArray[index].id == document.documentID {
                                    self.groupsArray[index] = groups
                                    found = true
                                    break
                                }
                            }
                            if !found {
                                self.groupsArray.append(groups)
                            }
                            DispatchQueue.main.async {
                                self.groups = self.groupsArray
                            }
                        }
                        self.groupListeners.append(groupListen)
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
                var colorDictionary: [[String:String]] = [[:]]
                for document in querySnapshot!.documents {
                    let riskRange = RiskHighLow(snapshot: document.data())
                    var s = [String:RiskHighLow]()
                    s[riskRange.name] = riskRange
                    dictionary.append(s)
                    var color = [String: String]()
                    color[riskRange.name] = riskRange.color
                    colorDictionary.append(color)
                }
                print(dictionary)
                self.riskRanges.removeAll()
                self.riskColors.removeAll()
                DispatchQueue.main.async {
                    self.riskRanges = dictionary
                    self.riskColors = colorDictionary
                }
                completion(nil)
            }
        }
    }
    
    func getRiskString(value: Double) -> String {
        
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
