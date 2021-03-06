//
//  WebService.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/20/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import Firebase
import Contacts

enum Endpoint {
    case createUser
    case createGroup
    case addUserToPod(groupId: String)
    case removeUserFromPod(groupId: String)
    case acceptInvite(groupId: String)
    case declineInvite(groupId: String)
    case leavePod(groupId: String)
    case postStatus(groupId: String)
    case postQuestionAnswers
    case postGroupAnswers
    case checkPhoneNumbers
    case inviteUser
    case deleteGroup(groupId: String)
    case location
    case riskScore
    case leaveGroup(groupId: String)
    case removeUser(groupId: String)
    case addFCMToken
    
    var baseUrlString: String {
        //TODO: move this into its own ENUM at some point in order to switch between staging/dev/prod server environments
        return "https://us-central1-together-c537f.cloudfunctions.net/api/"
    }
    
    var method: HTTPMethod {
        switch self {
        
        case .createUser,
             .createGroup,
             .addUserToPod,
             .removeUserFromPod,
             .acceptInvite,
             .declineInvite,
             .leavePod,
             .postStatus,
             .postQuestionAnswers,
             .postGroupAnswers,
             .checkPhoneNumbers,
             .inviteUser,
             .location,
             .riskScore,
             .leaveGroup,
             .removeUser,
             .addFCMToken:
            return .post
        case .deleteGroup:
            return .delete
        }
    }
    
    var route: String {
        switch self {
            
        case .createUser:
            return "users/create"
        case .createGroup:
            return "groups/create"
        case .addUserToPod(groupId: let groupId):
            return "groups/\(groupId)/inviteUser"
        case .removeUserFromPod(groupId: let groupId):
            return "groups/\(groupId)/removeUser"
        case .acceptInvite(groupId: let groupId):
            return "groups/\(groupId)/accept"
        case .declineInvite(groupId: let groupId):
            return "groups/\(groupId)/decline"
        case .leavePod(groupId: let groupId):
            return "groups/\(groupId)/leave"
        case .postStatus(groupId: let groupId):
            return "groups/\(groupId)/status"
        case .postQuestionAnswers:
            return "answers"
        case .postGroupAnswers:
            return "answerQuestions"
        case .checkPhoneNumbers:
            return "checkPhoneNumbers"
        case .inviteUser:
            return "invites/create"
        case .deleteGroup(groupId: let groupId):
            return "groups/\(groupId)"
        case .location:
            return "users/location"
        case .riskScore:
            return "users/riskScore"
        case .leaveGroup(groupId: let groupId):
            return "groups/\(groupId)/leave"
        case .removeUser(groupId: let groupId):
            return "groups/\(groupId)/removeUser"
        case .addFCMToken:
            return "users/addFCMToken"
        }
    }
}

enum NetworkingError: Error {
    case invalidUrl
    case invalidToken
    case serializationError(message: String)
    case serverError(message: String)
    case requestResponseError(response: URLResponse?)
    case generalError(error: Error)
}

public enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete  = "DELETE"
    case get     = "GET"
    case head    = "HEAD"
    case options = "OPTIONS"
    case patch   = "PATCH"
    case post    = "POST"
    case put     = "PUT"
    case trace   = "TRACE"
}

protocol WebServiceResponse: Decodable {
    var message: String {get}
}

class WebService {
    //MARK:- Response Structs
    struct GenericMessageResponse: WebServiceResponse {
        let message: String
    }
    
    struct CheckPhonenumberResponse: WebServiceResponse {
        let message: String
        let userPhoneNumbers: [String]
        let invitedPhoneNumbers: [String]
        let invitablePhoneNumbers: [String]
    }
    
    struct CreateNewGroupResponse: WebServiceResponse {
        let message: String
        let groupId: String
    }
    
    //MARK:- Request Methods
    
    static func updateLocation(lat: Float, lng: Float, completion: @escaping (Bool) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["latitude" : lat, "longitude" : lng], options: [])
        networkRequest(.location, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func riskScore(score: Float, completion: @escaping (Bool) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["riskScore": score], options: [])
        networkRequest(.riskScore, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func acceptInviteToGroup(groupId: String, completion: @escaping (Bool) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: [String : Any](), options: [])
        networkRequest(.acceptInvite(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func declineInviteToGroup(groupId: String, completion: @escaping (Bool) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: [String : Any](), options: [])
        networkRequest(.declineInvite(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func inviteUserToGroup(groupId: String, phoneNumber: String, completion: @escaping (Bool, NetworkingError?) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["newMember" : phoneNumber], options: [])
        networkRequest(.addUserToPod(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil, error)
        }
    }
    
    static func createInvite(phoneNumber: String, completion: @escaping (Bool, NetworkingError?) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["phoneNumber" : phoneNumber], options: [])
        networkRequest(.inviteUser, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil, error)
        }
    }
    
    static func checkPhoneNumbers(phoneNumbers: [String], completion: @escaping (CheckPhonenumberResponse) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["phoneNumbers" : phoneNumbers], options: [])
        networkRequest(.checkPhoneNumbers, responseType: CheckPhonenumberResponse.self, requestBody: requestBody) { (response, error) in
            if let response = response {
                completion(response)
            } else {
                completion(CheckPhonenumberResponse(message: "", userPhoneNumbers: [], invitedPhoneNumbers: [], invitablePhoneNumbers: []))
            }
        }
    }
    
    static func createUser(successful: @escaping (Bool) -> Void)  {
        let phoneNumber = UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
        let requestBody = try? JSONSerialization.data(withJSONObject: ["phoneNumber" : phoneNumber], options: [])
        networkRequest(.createUser, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            successful(error == nil)
        }
    }
    
    static func createNewGroup(name: String, members: [String], successful: @escaping (Bool, NetworkingError?) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["name" : name, "members" : members], options: [])
        networkRequest(.createGroup, responseType: CreateNewGroupResponse.self, requestBody: requestBody) { (response, error) in
            successful(error == nil, error)
        }
    }
    
    static func setStatus(text: String, emoji: String, groupId: String, completion: @escaping (Bool) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["emoji" : emoji, "text" : text], options: [])
        networkRequest(.postStatus(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func postQuestionAnswers(answers: [UserAnswer], completion: @escaping (Bool) -> Void) {
        let mappedAnswers = answers.map { (answer) -> [String : Any?] in
            return ["userQuestion" : answer.userQuestion, "answer" : answer.answer as Bool?]
        }
        let requestBody = try? JSONSerialization.data(withJSONObject: ["answers" : mappedAnswers], options: [])
        networkRequest(.postQuestionAnswers, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func postGroupAnswers(answers: [QuestionGroupsAnswer], completion: @escaping (Bool) -> Void) {
        let mappedAnswers = answers.map { (answer) -> [String : Any?] in
            return ["questionGroup" : answer.questionGroup, "question" : answer.question, "answer" : answer.answer]
        }
        let requestBody = try? JSONSerialization.data(withJSONObject: ["answers" : mappedAnswers], options: [])
        networkRequest(.postGroupAnswers, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func leaveGroup(groupId: String, completion: @escaping (Bool, NetworkingError?) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: [], options: [])
        networkRequest(.leaveGroup(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil, error)
        }
    }
    
    static func deleteGroup(groupId: String, completion: @escaping (Bool, NetworkingError?) -> Void)  {
        networkRequest(.deleteGroup(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: nil) { (response, error) in
            completion(error == nil, error)
        }
    }
    
    static func removeUser(groupId: String, phoneNumber: String, completion: @escaping (Bool, NetworkingError?) -> Void)  {
        let requestBody = try? JSONSerialization.data(withJSONObject: ["userToRemove" : phoneNumber], options: [])
        networkRequest(.removeUser(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil, error)
        }
    }
    
    static func addFCMToken(token: String, completion: @escaping (Bool, NetworkingError?) -> Void)  {
        let phoneNumber = UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
        let requestBody = try? JSONSerialization.data(withJSONObject: ["FCMToken" : token, "phoneNumber" : phoneNumber], options: [])
        networkRequest(.addFCMToken, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil, error)
        }
    }
}

private extension WebService {
    static func networkRequest<T: WebServiceResponse>(_ endpoint: Endpoint, responseType: T.Type, requestBody: Data?, completion: @escaping (T?, NetworkingError?) -> Void) {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { token, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, .generalError(error: error))
                return
            }
            
            guard let token = token else {
                completion(nil, .invalidToken)
                return
            }
            guard let url = URL(string: endpoint.baseUrlString + endpoint.route) else {
                completion(nil, .invalidUrl)
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = endpoint.method.rawValue
            request.httpBody = requestBody
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(nil, .generalError(error: error))
                    return
                }
                if let data = data, let response = response as? HTTPURLResponse {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        if response.statusCode == 200 {
                            completion(result, nil)
                            return
                        } else {
                            completion(nil, .serverError(message: result.message))
                            return
                        }
                    } catch let error {
                        completion(nil, .serializationError(message: error.localizedDescription))
                        return
                    }
                } else {
                    completion(nil, .requestResponseError(response: response))
                }
            }.resume()
            
        }
    }
}
