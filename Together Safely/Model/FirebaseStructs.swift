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
    var userGroupAnswers: [QuestionGroupsAnswer]
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

struct Invite: Hashable, Identifiable {
    let id = UUID()
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

struct Choice: Codable, Identifiable, Hashable {
    let id = UUID()
    let text: String
    let value: Double
}

struct Questions: Codable, Identifiable {
    let id = UUID()
    let choices: [Choice]
    let text: String
    let type: String
    var userResponse: Int?
}

struct QuestionGroups: Identifiable, Codable {
    @DocumentID var id: String?
    let order: Int
    var questions: [Questions]
    let text: String
}

struct QuestionGroupsAnswer: Codable, Hashable {
    var answer: Int
    let question: Int
    let questionGroup: String
    let questionId: UUID
    let groupIndexs: [Int]
    let groupNumber: Int
}

struct QuestionGroupsAnswers: Codable, Hashable {
    let answers: [QuestionGroupsAnswer]
}

extension QuestionGroupsAnswers {
    init(groups: [QuestionGroups]) {

        var answers: [QuestionGroupsAnswer] = []
        for (groupIndex, group) in groups.enumerated() {
            let id = group.id != nil ? group.id! : ""
            for (questionIndex, question) in group.questions.enumerated() {
                let response = question.userResponse != nil ? question.userResponse! : 9999
                var array: [Int] = []
                for (count, _) in question.choices.enumerated() {
                    let id = groupIndex * 100 + questionIndex * 10 + count
                    array.append(id)
                }
                let answer = QuestionGroupsAnswer(answer: response, question: questionIndex, questionGroup: id, questionId: question.id, groupIndexs: array, groupNumber: groupIndex)
                answers.append(answer)
            }
        }
        
        self.answers = answers
    }
}

extension QuestionGroups {
    init(snapshot: Dictionary<String, Any>, groupID: String, answers: [QuestionGroupsAnswer]) {
        let answers = answers.filter { $0.questionGroup == groupID }
        order = snapshot["order"] as? Int ?? 0
        text = snapshot["text"] as? String ?? ""
        let array = snapshot["questions"] as? Array ?? []
        questions = []
        for (index, item) in array.enumerated() {
            let i = item as! Dictionary<String, Any>
            let text = i["text"] as? String ?? ""
            let type = i["type"] as? String ?? ""
            let cc = i["choices"] as? Array ?? []
            
            var choices: [Choice] = []
            for c in cc {
                let y = c as! Dictionary<String, Any>
                let text = y["text"] as? String ?? ""
                let value = y["value"] as? Double ?? 0
                let choice = Choice(text: text, value: value)
                choices.append(choice)
            }
            
            let question = Questions(choices: choices, text: text, type: type, userResponse: index > answers.count - 1 ? nil : answers[index].answer)
            questions.append(question)
        }
        
    }
}

extension GroupInvites {
    init(snapshot: Dictionary<String, Any>) {
        let invites = snapshot["groupInvites"] as? Array ?? []
        groupInvites = []
        for invite in invites {
            let i = invite as? String ?? ""
            groupInvites.append(i)
        }
    }
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
        
        let groupAnswersCollection = snapshot["answers"] as? [[String : AnyObject]] ?? []
        var userGroupAnswers = [QuestionGroupsAnswer]()
        for answer in groupAnswersCollection {
            let userAnswer = answer["answer"] as? Int ?? 9999
            let question = answer["question"] as? Int ?? 9999
            let questionGroup = answer["questionGroup"] as? String ?? ""
            userGroupAnswers.append(QuestionGroupsAnswer(answer: userAnswer, question: question, questionGroup: questionGroup, questionId: UUID(), groupIndexs: [], groupNumber: 0))
        }
        self.userGroupAnswers = userGroupAnswers
    }
}
