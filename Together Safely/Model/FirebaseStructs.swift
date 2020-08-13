//
//  FirebaseStructs.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/27/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI
import Contacts

enum TogetherContactTypes: Comparable {
    case invitablePhoneNumber
    case invitedPhoneNumber
    case userPhoneNumber
    
    var sortOrder: Int {
        switch self {
            case .userPhoneNumber:
                return 0
            case .invitedPhoneNumber:
                return 1
            case .invitablePhoneNumber:
                return 2
        }
    }

    static func <(lhs: TogetherContactTypes, rhs: TogetherContactTypes) -> Bool {
       return lhs.sortOrder < rhs.sortOrder
    }
}

struct TogetherContactType: Hashable, Identifiable {
    let id = UUID()
    var contactInfo: CNContact
    var type: TogetherContactTypes
    var phoneNumber: String
    var riskScore: Double?
    var riskString: String?
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var image: Data?
    var phoneNumber: String
    var groups: [String]
    var riskScore: Double
    var riskString: String
    var groupInvites: [String]
    var userAnswers: [UserAnswer]
}

struct RiskScores: Equatable {
    let date: Int
}

struct UserQuestion: Identifiable, Codable {
    @DocumentID var id: String?
    let order: Int
    let primary: Bool
    let text: String
    let type: String
    //this value is not part of the data set coming from firebase, but we can use it to track the user's selection locally when we prepare to submit the response
    var userResponse: Bool?
}

struct UserAnswer: Codable, Hashable {
    let answer: Bool?
    let userQuestion: String
}

struct Groups: Identifiable, Codable, Hashable {
    var id: String
    var adminId: String
    var name: String
    var members: [Member]
    var riskTotals: [String : Int]
    var riskCompiledSring: [String]
    var riskCompiledValue: [Int]
    var averageRisk: String
    var averageRiskValue: Double
}

struct Member: Identifiable, Codable, Hashable {
    var id: String
    var adminId: String
    var phoneNumber: String
    var riskScore: Double
    var status: Status
    var riskString: String
    var riskIndex: Int
    var memberName: String
}

struct Status: Codable, Hashable {
    var emoji: String
    var text: String
}

struct RiskHighLow: Codable, Hashable {
    var min: Double
    var max: Double
}

struct RiskRanges {
    var dicRiskRange: [String : RiskHighLow]
}

extension RiskHighLow {
    init(snapshot: Dictionary<String, Any>) {
        min = snapshot["min"] as? Double ?? 9999999
        max = snapshot["max"] as? Double ?? 9999999
    }
}

struct GroupInvites {
    var groupInvites: [String]
}

struct Invite: Hashable {
    var adminName: String?
    var adminPhone: String
    var groupName: String
    var groupId: String
    var riskScore: Double
}

struct ContactInfo: Hashable {
    var image: Data?
    var name: String
}

extension Groups {
    init(snapshot: Dictionary<String, Any>) {
        adminId = snapshot["admin"] as? String ?? ""
        id = snapshot["id"] as? String ?? ""
        name = snapshot["name"] as? String ?? ""
        members = []
        riskTotals = [:]
        riskCompiledSring = []
        riskCompiledValue = []
        let members = snapshot["members"] as? Array ?? []
        averageRisk = "N/A"
        averageRiskValue = 0
        
        for element in members {
            let m = element as? [String : Any] ?? [:]
            let uid = m["uid"] as? String ?? ""
            let phoneNumber = m["phoneNumber"] as? String ?? ""
            let doubleValue = m["riskScore"] as? Double ?? 99999
            let riskScore = doubleValue
            let stat = m["status"] as? Dictionary<String, Any>  ?? [:]
            let status = Status(emoji: stat["emoji"] as? String ?? "", text: stat["text"] as? String ?? "")
            let member = Member(uID: uid, phone: phoneNumber, risk: riskScore, stat: status)
            self.members.append(member)
        }
    }
}

extension Member {
    init(uID: String, phone: String, risk: Double, stat: Status) {
        self.id = ""
        self.adminId = uID
        self.phoneNumber = phone
        self.riskScore = risk
        self.status = stat
        self.riskString = ""
        self.riskIndex = 99999
        self.memberName = ""
    }
}

extension User {
    init(snapshot: Dictionary<String, Any>) {
        id = snapshot["id"] as? String ?? ""
        phoneNumber = snapshot["phoneNumber"] as? String ?? ""
        let array = snapshot["groups"] as? Array ?? []
        var g: [String] = []
        for groupId in array {
            g.append(groupId as? String ?? "")
        }
        groups = g
        let doubleValue = snapshot["riskScore"] as? Double ?? 99999
        riskScore = doubleValue
        riskString = ""
        name = ""
        var groupInvites: [String] = []
        let array2 = snapshot["groupInvites"] as? Array ?? []
        for groupInvite in array2 {
            groupInvites.append(groupInvite as? String ?? "")
        }
        self.groupInvites = groupInvites
        let answersCollection = snapshot["userAnswers"] as? [[String : AnyObject]] ?? []
        var userAnswers = [UserAnswer]()
        for answer in answersCollection {
            let userAnswer = answer["answer"] as? Bool
            let questionId = answer["userQuestion"] as? String ?? ""
            userAnswers.append(UserAnswer(answer: userAnswer, userQuestion: questionId))
        }
        self.userAnswers = userAnswers
    }
}

        
/*
        addressString = (dictionary["address"] as? String) ?? ""
        
        let categoryString = (dictionary["category"] as? String) ?? ""
        category = Category(rawValue: categoryString) ?? .greatFood
        let otherDescription = (dictionary["description"] as? String) ?? ""
        if otherDescription.count > 0 {
            desc = [otherDescription]
        } else {
            desc = (dictionary["desc"] as? [String]) ?? [""]
        }
        imgUrlMO = (dictionary["imgUrlMO"] as? String) ?? ""
        if imgUrlMO.count > 0 {
            imageURL = imgUrlMO
        } else {
            imageURL = (dictionary["imageURL"] as? String) ?? ""
            if imageURL.count > 0 {
                imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(imageURL)&key=AIzaSyAKLWDaXfuVGwqjHBMXSttTNhD3gtvj2vs"
            }
        }
        lat = (dictionary["lat"] as? Double) ?? 0.0
        lon = (dictionary["lon"] as? Double) ?? 0.0
        name = (dictionary["name"] as? String) ?? ""
        phone = (dictionary["phone"] as? String) ?? ""
        url = (dictionary["url"] as? String) ?? ""
        time = (dictionary["time"] as? [String]) ?? [""]
        var offers: [Offers] = []
        if let object = dictionary["offers"] as? Dictionary<String, Any> {
            let aa = object.keys
            for a in aa {
                if let b = object[a] as? [String:Any] {
                    let offer: Offers = Offers.init(active: b["active"] != nil ? b["active"]! as! String :  "",
                                                code: b["code"] != nil ? b["code"]! as! String :  "",
                                                codeDescription: b["codeDescription"] != nil ? b["codeDescription"]! as! String :  "",
                                                businessDescription: b["businessDescription"] != nil ? b["businessDescription"]! as! String :  "")
                    offers.append(offer)
                }
            }
        }
/*
        if let objects = dictionary["offers"] as? NSArray {
            for object in objects {
                if let dict = object as? Dictionary<String, String> {
                    let offer: Offers = Offers.init(active: dict["active"] ?? "",
                                                code: dict["code"] ?? "",
                                                codeDescription: dict["codeDescription"] ?? "",
                                                businessDescription: dict["businessDescription"] ?? "")
                    offers.append(offer)
                }
            }
        }
*/
        self.offers = offers
        distance = 0
*/
