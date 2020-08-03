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

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var phoneNumber: String
    var groups: [String]
    var riskScore: Int
    var groupInvites: [String]
}

struct RiskScores: Equatable {
    let date: Int
}

struct Groups: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var members: [Member]
    var riskTotals: [String : Int]
    var riskCompiledSring: [String]
    var riskCompiledValue: [Int]
    var averageRisk: String
}

struct Member: Identifiable, Codable, Hashable {
    var id: String
    var adminId: String
    var phoneNumber: String
    var riskScore: Int
    var status: Status
    var riskString: String
    var riskIndex: Int
}

struct Status: Codable, Hashable {
    var emoji: String
    var text: String
}

struct RiskHighLow: Codable, Hashable {
    var min: Int
    var max: Int
}

struct RiskRanges {
    var dicRiskRange: [String : RiskHighLow]
}

extension RiskHighLow {
    init(snapshot: Dictionary<String, Any>) {
        min = snapshot["min"] as? Int ?? 9999999
        max = snapshot["max"] as? Int ?? 9999999
    }
}

struct GroupInvites {
    var groupInvites: [String]
}

struct Invite: Hashable {
    var adminName: String
    var groupName: String
    var groupId: String
    var riskScore: Int
}

extension Groups {
    init(snapshot: Dictionary<String, Any>) {
        id = snapshot["admin"] as? String ?? ""
        name = snapshot["name"] as? String ?? ""
        members = []
        riskTotals = [:]
        riskCompiledSring = []
        riskCompiledValue = []
        let members = snapshot["members"] as? Array ?? []
        averageRisk = "N/A"
        
        for element in members {
            let m = element as? [String : Any] ?? [:]
            let uid = m["uid"] as? String ?? ""
            let phoneNumber = m["phoneNumber"] as? String ?? ""
            let riskScore = m["riskScore"] as? Int ?? 99999
            let stat = m["status"] as? Dictionary<String, Any>  ?? [:]
            let status = Status(emoji: stat["emoji"] as? String ?? "", text: stat["text"] as? String ?? "")
            let member = Member(uID: uid, phone: phoneNumber, risk: riskScore, stat: status)
            self.members.append(member)
        }
    }
}

extension Member {
    init(uID: String, phone: String, risk: Int, stat: Status) {
        self.id = ""
        self.adminId = uID
        self.phoneNumber = phone
        self.riskScore = risk
        self.status = stat
        self.riskString = ""
        self.riskIndex = 99999
    }
}

extension User {
    init(snapshot: Dictionary<String, Any>) {
        id = snapshot["name"] as? String ?? ""
        phoneNumber = snapshot["phoneNumber"] as? String ?? ""
        let array = snapshot["groups"] as? Array ?? []
        var g: [String] = []
        for groupId in array {
            g.append(groupId as? String ?? "")
        }
        groups = g
        riskScore = snapshot["riskScore"] as? Int ?? 99999
        var groupInvites: [String] = []
        let array2 = snapshot["groupInvites"] as? Array ?? []
        for groupInvite in array2 {
            groupInvites.append(groupInvite as? String ?? "")
        }
        self.groupInvites = groupInvites
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
