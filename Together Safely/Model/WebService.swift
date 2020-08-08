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
    case checkPhoneNumbers
    case inviteUser
    case deleteGroup(groupId: String)
    
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
             .checkPhoneNumbers,
             .inviteUser:
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
        case .checkPhoneNumbers:
            return "invitablePhoneNumbers"
        case .inviteUser:
            return "invites/create"
        case .deleteGroup(groupId: let groupId):
            return "groups/\(groupId)"
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
    static func acceptInviteToGroup(groupId: String, completion: @escaping (Bool) -> Void)  {
        let requestBody = [String : AnyObject]()
        networkRequest(.acceptInvite(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func inviteUserToGroup(groupId: String, phoneNumber: String, completion: @escaping (Bool) -> Void)  {
        let requestBody = ["newMember" : phoneNumber] as [String : AnyObject]
        networkRequest(.addUserToPod(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func createInvite(contact: CNContact, completion: @escaping (Bool) -> Void)  {
        var phoneNumber = ""
        for phone in contact.phoneNumbers {
            if let label = phone.label {
                if label == CNLabelPhoneNumberMobile {
                    var number = phone.value.stringValue
                    number = format(with: "+1XXXXXXXXXX", phone: number)
                    phoneNumber = number
                    break
                }
            }
        }
        
        if phoneNumber.count == 0 {
            print("createInvite no phoneNumber found for contact")
            completion(false)
        }
        
        let requestBody = ["phoneNumber" : phoneNumber] as [String : AnyObject]
        networkRequest(.inviteUser, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func checkPhoneNumbers(phoneNumbers: [String], completion: @escaping ([String]) -> Void)  {
        let requestBody = ["phoneNumbers" : phoneNumbers] as [String : AnyObject]
        networkRequest(.inviteUser, responseType: CheckPhonenumberResponse.self, requestBody: requestBody) { (response, error) in
            if let response = response {
                completion(response.invitablePhoneNumbers)
            } else {
                completion([String]())
            }
        }
    }
    
    static func createUser(successful: @escaping (Bool) -> Void)  {
        let username = UserDefaults.standard.value(forKey: "username") as? String ?? ""
        let phoneNumber = UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
        let requestBody = ["username" : username, "phoneNumber" : phoneNumber] as [String : AnyObject]
        networkRequest(.inviteUser, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            successful(error == nil)
        }
    }
    
    static func createNewGroup(name: String, members: [String], successful: @escaping (Bool) -> Void)  {
        let requestBody = ["name" : name, "members" : members] as [String : AnyObject]
        networkRequest(.inviteUser, responseType: CreateNewGroupResponse.self, requestBody: requestBody) { (response, error) in
            successful(error == nil)
        }
    }
    
    
    
    static func setStatus(text: String, emoji: String, groupId: String, completion: @escaping (Bool) -> Void)  {
        let requestBody = ["emoji" : emoji, "text" : text] as [String : AnyObject]
        networkRequest(.inviteUser, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
    
    static func postQuestionAnswers(answers: [UserAnswer], completion: @escaping (Bool) -> Void) {
        let mappedAnswers = answers.map { (answer) -> [String : AnyObject?] in
            return ["userQuestion" : answer.userQuestion as AnyObject, "answer" : answer.answer as AnyObject?]
        }
        let requestBody = ["answers" : mappedAnswers] as [String : AnyObject]
        networkRequest(.postQuestionAnswers, responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
            completion(error == nil)
        }
    }
}

private extension WebService {
    static func networkRequest<T: WebServiceResponse>(_ endpoint: Endpoint, responseType: T.Type, requestBody: [String : AnyObject]?, completion: @escaping (T?, NetworkingError?) -> Void) {
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
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = endpoint.method.rawValue
            
            if let requestBody = requestBody {
                do {
                    let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                    request.httpBody = bodyData
                } catch let error {
                    completion(nil, .serializationError(message: error.localizedDescription))
                    return
                }
            }
            
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
