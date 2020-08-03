//
//  UserService.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/27/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService: ObservableObject {
    @Published var phoneNumber:String = "XXXXXXX"
    @Published var riskScore: Int = 0
    @Published var user: User = User(snapshot: [:])
    @Published var groups: [Groups] = []
    @Published var riskRanges: [[String:RiskHighLow]] = []
    @Published var invites: [Invite] = []

    static let shared = FirebaseService()
    private var database = Firestore.firestore()
    private var groupsArray: [Groups] = []

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


    func getUserData(byPhoneNumber phoneNumber: String) {
        if riskRanges.count == 0 {
            getRiskRanges{ error in
                guard error == nil else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
                self.getUserData(byPhoneNumber: phoneNumber) { error in
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
        getUserData(byPhoneNumber: phoneNumber) { error in
                guard error == nil else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
        }
    }
    
    func getUserData(byPhoneNumber phoneNumber: String, completion: @escaping (Error?) -> Void) {
    
        self.database.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    completion(error)
                    return
                }
                if documents.count == 1 {
                    let doc = querySnapshot!.documents[0]
                    let user = User(snapshot: doc.data())
                    DispatchQueue.main.async {
                        self.user = user
                    }
                    
                    var invites: [Invite] = []
                    for invite in user.groupInvites {
                        let docRef = self.database.collection("groups").document(invite)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let group = Groups(snapshot: document.data() ?? [:])
                                var invite:Invite = Invite(adminName: "", groupName: group.name, groupId: group.id, riskScore: 99999)
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
