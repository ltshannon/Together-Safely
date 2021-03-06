//
//  DataController.swift
//  Together Safely
//
//  Created by Larry Shannon on 11/15/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import CoreData
import SwiftUI
import Firebase
import FirebaseAuth
import Contacts

class DataController: ObservableObject {

//    @Published var contactInfo: [[String:ContactInfo]] = []
    @Published var user: User = User(snapshot: [:])
    @Published var userContantRiskAverageString = ""
    @Published var userContantRiskAverageValue = 0.0
    @Published var userContantRiskAverageDict: [String : Int] = [:]
    @Published var userContantUsersCount = 0
    private var userName: String = ""
    private var userImage: Data?
    private var allUsers: [User] = []
    private var userContacts: [TogetherContactType] = []
    private var riskRanges: [[String:RiskHighLow]] = []
    private var riskColors: [[String:String]] = []
    let context = DataController.appDelegate.persistentContainer.viewContext
    private var database = Firestore.firestore()
    var isInitialized: Bool = false
    
    init() {

    }
    
    func login() {
        PhoneAuthProvider.provider().verifyPhoneNumber("+15555555551", uiDelegate: nil) { (id, err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                return
            }
            if let id = id {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: "555551")
                Auth.auth().signIn(with: credential) { (res, error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                        return
                    }
                    if let authData = res {
                        let user = authData.user
                        if let p = user.phoneNumber {
                            print(p)
                        }
                    }
                }
            }
        }
    }
    
    func getMobileNumber(numbers: [CNLabeledValue<CNPhoneNumber>]) -> String {
        
        for phone in numbers {
            if let label = phone.label {
                if label == CNLabelPhoneNumberMobile {
                    var number = phone.value.stringValue
                    number = number.deletingPrefix("+")
                    number = number.deletingPrefix("1")
                    number = format(with: "+1XXXXXXXXXX", phone: number)
                    return number
                }
            }
        }
        for phone in numbers {
            var number = phone.value.stringValue
            number = number.deletingPrefix("+")
            number = number.deletingPrefix("1")
            number = format(with: "+1XXXXXXXXXX", phone: number)
            return number
        }
        
        return ""
    }
    
    func getContacts(byPhoneNumber: String, completion: @escaping (Bool) -> Void) {
        
        isInitialized = true
        let database = Firestore.firestore()
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
//            let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
            var cinfo: [[String:ContactInfo]] = []

            
            for contact in contacts {
                let number = getMobileNumber(numbers: contact.phoneNumbers)
                if number.count > 0 {
                    let c: ContactInfo = ContactInfo(
                        image: contact.imageData,
                        name: "\(contact.givenName) " + "\(contact.familyName)"
                    )
         
                    cinfo.append([number:c])

                    if number.contains(byPhoneNumber) {
                        userName = "\(contact.givenName) " + "\(contact.familyName)"
                        if let imageData = contact.imageData {
                            userImage = imageData
                        }
                    }
                    phoneNumbers.append(number)
                }
            }

//            self.contactInfo = cinfo
             
            WebService.checkPhoneNumbers(phoneNumbers: phoneNumbers) { [self] returnedNumbers in

                for number in returnedNumbers.invitablePhoneNumbers {
                    print("invitablePhoneNumbers: \(number)")
                }
                for number in returnedNumbers.invitedPhoneNumbers {
                    print("invitedPhoneNumbers: \(number)")
                }
                for number in returnedNumbers.userPhoneNumbers {
                    print("userPhoneNumbers: \(number)")
                }
             
                userContacts.removeAll()
                for contact in contacts {
                        
                    let number = self.getMobileNumber(numbers: contact.phoneNumbers)
                    if number.count > 0 {
                        let c: TogetherContactType
                        if returnedNumbers.invitablePhoneNumbers.contains(number) {
                            c = TogetherContactType(name: contact.name, type: .invitablePhoneNumber, phoneNumber: number, imageData: contact.imageData, riskScore: nil, riskString: nil)
                        } else if returnedNumbers.invitedPhoneNumbers.contains(number) {
                            c = TogetherContactType(name: contact.name, type: .invitedPhoneNumber, phoneNumber: number, imageData: contact.imageData, riskScore: nil, riskString: nil)
                        } else {
                            c = TogetherContactType(name: contact.name, type: .userPhoneNumber, phoneNumber: number, imageData: contact.imageData, riskScore: nil, riskString: nil)
                        }
                        self.userContacts.append(c)
                    }

                }
                
                userContacts.sort { return $0.type.sortOrder < $1.type.sortOrder }
                
                self.getRiskRanges{ error in
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
                    database.collection("users").getDocuments() { (querySnapshot, err) in
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

                        self.deleteEntity(name: "CDContactInfo")
                        
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

                            let item = CDContactInfo(context: self.context)
                            item.name = self.userContacts[index].name
                            item.type = Int16(self.userContacts[index].type.sortOrder)
                            item.phoneNumber = self.userContacts[index].phoneNumber
                            item.imageData = self.userContacts[index].imageData
                            item.riskScore = self.userContacts[index].riskScore ?? 0
                            item.riskString = self.userContacts[index].riskString ?? ""
                        }

                        do {
                            try self.context.save()
                        }
                        catch {
                            print("error writing user: \(error.localizedDescription)")
                        }
                        
                        if userContactCount > 0 {
                            let average = userContactAverageRisk / userContactCount
                            self.userContantRiskAverageString = self.getRiskString(value: average)
                            self.userContantRiskAverageValue = average
                            self.userContantRiskAverageDict = dict
                            self.userContantUsersCount = Int(userContactCount)
                            self.deleteEntity(name: "CDRiskAverage")
                            let u = CDRiskAverage(context: self.context)
                            u.userContantUsersCount = Int16(self.userContantUsersCount)
                            u.userContantRiskAverageDict = try! JSONEncoder().encode(self.userContantRiskAverageDict)
                            u.userContantRiskAverageValue = self.userContantRiskAverageValue
                            u.userContantRiskAverageString = self.userContantRiskAverageString
                            do {
                                try self.context.save()
                            }
                            catch {
                                print("error writing user: \(error.localizedDescription)")
                            }
                        }
                    }
                    completion(true)
                }
            }
        } catch {
            print("Fetching contacts: failed with %@", error.localizedDescription)
        }
    }

    func startListeners(phoneNumber: String, completion: @escaping (Bool) -> Void) {

        let database = Firestore.firestore()
        var groupListeners: [ListenerRegistration?] = []
    
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .medium
        var localDate = dateFormatter.string(from: Date())
        
        database.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber)
            .addSnapshotListener { [self] querySnapshot, error in
                guard let userDocuments = querySnapshot?.documents else {
                    print("Error fetching documents: users")
                    return
                }
                
                localDate = dateFormatter.string(from: Date())
                print("Received Firebase data for users document: \(localDate)")
                if userDocuments.count == 1 {
                    let doc = querySnapshot!.documents[0]
                    var user = User(snapshot: doc.data())
                    user.id = doc.documentID
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    user.riskString = self.getRiskString(value: user.riskScore)
                    user.name = self.userName
                    user.image = self.userImage
                    self.user = user
                    
                    self.deleteEntity(name: "CDUser")
                    let u = CDUser(context: context)
                    u.id = user.id
                    u.userName = user.name
                    u.image = user.image
                    u.phoneNumber = user.phoneNumber
                    u.riskScore = user.riskScore
                    u.riskString = user.riskString
                    do {
                        try context.save()
                    }
                    catch {
                        print("error writing user: \(error.localizedDescription)")
                    }

                    querySnapshot!.documentChanges.forEach { diff in
                        print("User documentChanges: \(diff.document.data()) type: \(diff.type == .added ? "Add" : diff.type == .modified ? "Modified" :  diff.type == .removed ? "Removed" : "nothing")")
                        if (diff.type == .added || diff.type == .modified) {
                            print("Add or modified")
                            self.deleteEntity(name: "CDInvites")
                            let item = GroupInvites(snapshot: diff.document.data())
                            for invite in item.groupInvites {
                                let docRef = database.collection("groups").document(invite)
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let fetchRequest: NSFetchRequest<CDInvites> = CDInvites.fetchRequest()
                                        fetchRequest.predicate = NSPredicate(format: "groupId == %@", invite)
                                        if let result = try? context.fetch(fetchRequest) {
                                            if result.count == 0 {
                                                let group = Groups(snapshot: document.data() ?? [:])
                                                localDate = dateFormatter.string(from: Date())
                                                print("Firebase data for invite for group: \(invite) : \(localDate)")
                                                var invite: Invite = Invite(adminName: "", adminPhone: "", groupName: group.name, groupId: invite, riskScore: 99999)
                                                for user in self.allUsers {
                                                    if user.id == group.adminId {
                                                        invite.riskScore = user.riskScore
                                                        invite.adminPhone = user.phoneNumber
                                                        invite.adminName = user.name
                                                        let i = CDInvites(context: context)
                                                        i.adminName = invite.adminName
                                                        i.adminPhone = invite.adminPhone
                                                        i.groupId = invite.groupId
                                                        i.groupName = invite.groupName
                                                        i.riskScore = invite.riskScore
                                                        do {
                                                            try context.save()
                                                        }
                                                        catch {
                                                            print("error writing invite: \(error.localizedDescription)")
                                                        }
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        print("Group document for group id: \(invite) not found")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Check to see if group has been deleted
                    print("Check to see if group has been deleted")
                    let fetchRequest: NSFetchRequest<CDGroups> = CDGroups.fetchRequest()
                    if let result = try? context.fetch(fetchRequest) {
                        if result.count > 0 {
                            for i in 0...result.count-1 {
                                if let number = result[i].groupId {
                                    if !user.groups.contains(number) {
                                        print("deleting group: \(number)")
                                        context.delete(result[i])
                                    }
                                }
                            }
                        }
                        do {
                            try context.save()
                        }
                        catch {
                            print("error writing members: \(error.localizedDescription)")
                        }
                    }

                    localDate = dateFormatter.string(from: Date())
                    for listener in groupListeners {
                        if let listen = listener {
                            print("Group listener being removed: \(localDate)")
                            listen.remove()
                        }
                    }
                    
                    groupListeners.removeAll()
                    localDate = dateFormatter.string(from: Date())
                    print("Received Firebase data for \(user.groups.count) groups at: \(localDate)")
                    deleteEntity(name: "CDListOfGroups")

                    for group in user.groups {
                        
                        let l = CDListOfGroups(context: context)
                        l.groupId = group
                        do {
                            try context.save()
                        }
                        catch {
                            print("error writing user: \(error.localizedDescription)")
                        }
                        
                        let groupListen = database.collection("groups").whereField("id", isEqualTo: group)
                            .addSnapshotListener { [self] documentSnapshot, error in
                            guard let groupDocument = documentSnapshot else {
                                print("Error fetching document")
                                return
                            }
                            
                            var messageCnt = 0

                            localDate = dateFormatter.string(from: Date())
                            print("Received Firebase data for group document: \(group) at: \(localDate)")
                            print(groupDocument)

                            if groupDocument.count == 0 {
                                documentSnapshot!.documentChanges.forEach { diff in
                                    print("Data: \(diff.document.data())")
                                    if (diff.type == .removed) {
                                        let fetchRequest2: NSFetchRequest<CDMember> = CDMember.fetchRequest()
                                        fetchRequest2.predicate = NSPredicate(format: "groupId == %@", group)
                                        if let result2 = try? context.fetch(fetchRequest2) {
                                            for result in result2 {
                                                context.delete(result)
                                            }
                                        }
                                        let fetchRequest: NSFetchRequest<CDGroups> = CDGroups.fetchRequest()
                                        fetchRequest.predicate = NSPredicate(format: "groupId == %@", group)
                                        if let result = try? context.fetch(fetchRequest) {
                                            if result.count == 1 {
                                                print("\(result[0].groupId ?? "") \(result[0].name ?? "")")
                                                print("deleting group: \(group) from CD")
                                                context.delete(result[0])
                                            }
                                        }
                                        do {
                                            try context.save()
                                        } catch {
                                            print("failed to delete group & members: \(group)  \(error.localizedDescription)")
                                        }
                                    }
                                }
                                return
                            }

                            let doc = groupDocument.documents[0]
                            var groups = Groups(snapshot: doc.data())

                            print("")
                            var dict: [String : Int] = [:]
                            var groupAverageRisk = 0.0
                            var arrayPhone: [String] = []

                            let fetchRequest: NSFetchRequest<CDMember> = CDMember.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "groupId == %@", groups.id)
                                
                            if let result = try? context.fetch(fetchRequest) {
                                for (index, member) in groups.members.enumerated() {
                                    arrayPhone.append(member.phoneNumber)
                                    groups.members[index].riskString = self.getRiskString(value: member.riskScore)
                                    if let total = dict[groups.members[index].riskString] {
                                        dict[groups.members[index].riskString] = total + 1
                                    }
                                    else {
                                        dict[groups.members[index].riskString] = 1
                                    }
                                    groupAverageRisk += member.riskScore
                                    
                                    if let i = getMember(phoneNumber: member.phoneNumber, members: result) {
                                        result[i].adminId = member.adminId
                                        result[i].phoneNumber = member.phoneNumber
                                        if result[i].textString != member.status.text {
                                            let messages = CDMessages(context: context)
                                            messages.groupId = groups.id
                                            messages.phoneNumber = member.phoneNumber
                                            messages.textString = member.status.text
                                            messages.timeStamp = Date()
                                            let count = result[i].newMessageCnt + 1
                                            result[i].newMessageCnt = count
                                        }
                                        messageCnt += Int(result[i].newMessageCnt)
                                        result[i].emoji = member.status.emoji
                                        result[i].textString = member.status.text
                                        result[i].riskString = groups.members[index].riskString
                                        result[i].riskScore = member.riskScore
                                        result[i].groupId = groups.id
                                    } else {
                                        let m = CDMember(context: context)
                                        m.adminId = member.adminId
                                        m.phoneNumber = member.phoneNumber
                                        m.emoji = member.status.emoji
                                        m.textString = member.status.text
                                        m.riskString = groups.members[index].riskString
                                        m.riskScore = member.riskScore
                                        m.groupId = groups.id
                                    }
                                }
                                print("groups.id: \(groups.id) name: \(groups.name)")
                                if result.count > 0 {
                                    for i in 0...result.count-1 {
//                                        print("result[\(i)]: \(result[i].phoneNumber ?? "")")
                                        if let number = result[i].phoneNumber {
                                            if !arrayPhone.contains(number) {
                                                print("deleting member: \(number)")
                                                context.delete(result[i])
                                            }
                                        }
                                    }
                                }
                                do {
                                    try context.save()
                                }
                                catch {
                                    print("error writing members: \(error.localizedDescription)")
                                }
                            }
                                
                            groups.newMessageCnt = messageCnt
                                
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


                            groups.id = doc.documentID
                            let fetchRequest2: NSFetchRequest<CDGroups> = CDGroups.fetchRequest()
                            fetchRequest2.predicate = NSPredicate(format: "groupId == %@", doc.documentID)
                            if let result = try? context.fetch(fetchRequest2) {
                                if result.count == 1 {
                                    print("\(result[0].groupId ?? "") \(result[0].name ?? "")")
                                    print("deleting group: \(groups.id) from CD")
                                    context.delete(result[0])
                                    do {
                                        try context.save()
                                    } catch {
                                        print("failed to delete group: \(doc.documentID)  \(error.localizedDescription)")
                                    }
                                }
                            }
                            print("")
                            addGroupToCD(group: groups)
                        }
                        groupListeners.append(groupListen)
                    }
                    completion(true)
                }
        }
    }
    
    func getMember(phoneNumber: String, members: [CDMember]) -> Int? {
        
        for (index, element) in members.enumerated() {
            if element.phoneNumber == phoneNumber {
                return index
            }
        }
        
        return nil
    }
    
    func addGroupToCD(group: Groups) {
        
        print("\n add groups:")
        let g = CDGroups(context: context)
        print("\(group.id) \(group.name)")
        g.groupId = group.id
        g.name = group.name
        g.adminId = group.adminId
        g.averageRisk = group.averageRisk
        g.averageRiskValue = group.averageRiskValue
        g.riskTotals = try! JSONEncoder().encode(group.riskTotals)
        g.groupCount = Int16(group.members.count)
        g.newMessageCnt = Int16(group.newMessageCnt)

        do {
            try context.save()
        }
        catch {
            print("error writing user: \(error.localizedDescription)")
        }
    }

    func getRiskRanges(completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        
        database.collection("riskRanges").getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(err)
            } else {
                var dictionary: [[String:RiskHighLow]] = []
                var colorDictionary: [[String:String]] = []
                for document in querySnapshot!.documents {
                    let riskRange = RiskHighLow(snapshot: document.data())
                    var s = [String:RiskHighLow]()
                    s[riskRange.name] = riskRange
                    dictionary.append(s)
                    var color = [String: String]()
                    color[riskRange.name] = riskRange.color
                    colorDictionary.append(color)
                }

                self.riskRanges.removeAll()
                self.riskColors.removeAll()
                self.deleteEntity(name: "CDRiskColors")

                for c in colorDictionary {
                    let item = CDRiskColors(context: self.context)
                    item.riskColors = try! JSONEncoder().encode(c)
                }
                for c in dictionary {
                    let item = CDRiskRanges(context: self.context)
                    item.riskRanges = try! JSONEncoder().encode(c)
                }
                do {
                    try self.context.save()
                }
                catch {
                    print("error writing riskColors: \(error.localizedDescription)")
                }
                
                self.riskRanges = dictionary
                self.riskColors = colorDictionary
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
    
    static var appDelegate: AppDelegate = {
        UIApplication.shared.delegate as! AppDelegate
    }()
    
    func deleteEntity(name: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)

        } catch {
            print("error deleting \(name)")
        }
    }
    
}

