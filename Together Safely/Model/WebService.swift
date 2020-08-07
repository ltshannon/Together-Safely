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

class WebService {
    struct GenericMessageResponse: Decodable {
        var message: String
    }
    
    func acceptInviteToGroup(groupId: String, completion: @escaping (Bool) -> Void)  {
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/groups/\(groupId)/accept")!
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
/*
         let id =  UserDefaults.standard.value(forKey: "authVerificationID") as? String ?? ""
        let code =  UserDefaults.standard.value(forKey: "verificationCode") as? String ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (res, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
*/
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return;
                }
               let idToken =  idToken ?? ""
                request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
        
                let body = [String: String]()
                let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        
                request.httpMethod = "POST"
                request.httpBody = bodyData
        
                let session = URLSession.shared
                let task = session.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("acceptInviteToGroup failed: \(error)")
                        completion(false)
                    } else if let data = data {
                        let result = try? JSONDecoder().decode(CreateInviteResponse.self, from: data)
                        if let result = result {
                            if result.message.contains("Group invite accepted. User added as a member of the group.") {
                                completion(true)
                                return
                            }
                            print("acceptInviteToGroup API call failed with error: \(result.message)")
                            completion(false)
                        }
                    } else {
                        print("acceptInviteToGroup API call failed")
                        completion(false)
                    }
                }
                task.resume()
            }
//        }

    }
    
    func inviteUserToGroup(groupId: String, phoneNumber: String, completion: @escaping (Bool) -> Void)  {
        //TODO: replace this method body with the following once we set up response message parsing to determine if an error ocurred or not
        /**
         let requestBody = ["newMember" : phoneNumber] as [String : AnyObject]
         networkRequest(.addUserToPod(groupId: groupId), responseType: GenericMessageResponse.self, requestBody: requestBody) { (response, error) in
         completion(error == nil)
         }
         */
        
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/groups/\(groupId)/inviteUser")!
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return;
            }
            let idToken =  idToken ?? ""
            request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
    
            let body = ["newMember" : phoneNumber]
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
    
            request.httpMethod = "POST"
            request.httpBody = bodyData
    
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Add friend failed: \(error)")
                    completion(false)
                } else if let data = data {
                    let result = try? JSONDecoder().decode(CreateInviteResponse.self, from: data)
                    if let result = result {
                        if result.message.contains("User invited to group.") {
                            completion(true)
                            return
                        }
                        print("Add friend API call failed with error: \(result.message)")
                        completion(false)
                    }
                } else {
                    print("Add friend API call failed")
                    completion(false)
                }
            }
            task.resume()
        }

    }
    
    struct CreateInviteResponse: Codable {
        var message: String
    }
    
    func createInvite(contact: CNContact, completion: @escaping (Bool) -> Void)  {
        
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
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/invites/create")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return;
                }
                let idToken =  idToken ?? ""
                request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
        
                let body = ["phoneNumber" : phoneNumber]
                let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        
                request.httpMethod = "POST"
                request.httpBody = bodyData
        
                let session = URLSession.shared
                let task = session.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Invite failed: \(error)")
                        completion(false)
                    } else if let data = data {
                        let result = try? JSONDecoder().decode(CreateInviteResponse.self, from: data)
                        if let result = result {
                            if result.message.contains("has been invited to join Together") {
                                completion(true)
                                return
                            }
                            print("Invite API call failed with error: \(result.message)")
                            completion(false)
                        }
                    } else {
                        print("Invite API call failed")
                        completion(false)
                    }
                }
                task.resume()
            }
    }
    
    struct CheckPhonenumberResponse: Codable {
        var userPhoneNumbers: [String]
        var invitedPhoneNumbers: [String]
        var invitablePhoneNumbers: [String]
    }
    
    func checkPhoneNumbers(phoneNumbers: [String], completion: @escaping ([String]) -> Void)  {
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/checkPhoneNumbers")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                completion([])
                return;
            }
            let idToken =  idToken ?? ""
            request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
        
            let body = ["phoneNumbers" : phoneNumbers]
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        
            request.httpMethod = "POST"
            request.httpBody = bodyData

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Create firebase user failed: \(error)")
                    completion([])
                } else if let data = data {
                    let result = try? JSONDecoder().decode(CheckPhonenumberResponse.self, from: data)
                    if let result = result {
                        if result.invitablePhoneNumbers.count == 0 {
                            print("")
                            completion([])
                            return
                        }
                        completion(result.invitablePhoneNumbers)
                    }
                } else {
                    print("Check phone numbers API failed")
                    completion([])
                }
            }
            task.resume()
        }
    }
    
    struct CreateUserResponse: Codable {
        var message: String
    }
    
    func createUser(successful: @escaping (Bool) -> Void)  {
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/users/create")!
        var request = URLRequest(url: url)
     
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                successful(false)
                return;
            }
            let idToken =  idToken ?? ""
            request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
            
            // Serialize HTTP Body data as JSON
            let username = UserDefaults.standard.value(forKey: "username") as? String ?? ""
            let phoneNumber = UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
            
            let body = ["username" : username, "phoneNumber" : phoneNumber]
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])

            // Change the URLRequest to a POST request
            request.httpMethod = "POST"
            request.httpBody = bodyData
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Create user API call failed: \(error)")
                    successful(false)
                } else if let data = data {
                    let result = try? JSONDecoder().decode(CreateUserResponse.self, from: data)
                    if let result = result {
                        if result.message != "User created successfully" {
                            print("Create user API, error returned: \(result.message)")
                            successful(false)
                        }
                        successful(true)
                    }
                } else {
                    print("Create API user call failed")
                    successful(false)
                }
            }
            task.resume()
        }
    }
    
    struct CreateNewGroupResponse: Codable {
        var message: String
        var groupId: String
    }
    
    func createNewGroup(name: String, members: [String], successful: @escaping (Bool) -> Void)  {
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/groups/create")!
        var request = URLRequest(url: url)
         
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                successful(false)
                return;
            }
            let idToken =  idToken ?? ""
            request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
            
            let emptyArray: [String] = []
            let body = ["name" : name, "members" : emptyArray] as [String : Any]
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])

            request.httpMethod = "POST"
            request.httpBody = bodyData
                
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Create group API failed: \(error)")
                    successful(false)
                } else if let data = data {
                    let result = try? JSONDecoder().decode(CreateNewGroupResponse.self, from: data)
                    if let result = result {
                        if result.message != "Group created successfully" {
                            print("Create group API, error returned: \(result.message)")
                            successful(false)
                            return
                        }
                        successful(true)
                    }
                } else {
                    print("Create API group call failed")
                    successful(false)
                }
            }
            task.resume()
        }
    }
    
    struct SetStatusResponse: Codable {
        var message: String
    }
    
    func setStatus(text: String, emoji: String, groupId: String, completion: @escaping (Bool) -> Void)  {
        
        let url = URL(string: "https://us-central1-together-c537f.cloudfunctions.net/api/groups/" + "\(groupId)" + "/status")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return;
            }
            let idToken =  idToken ?? ""
            request.setValue("Bearer " + idToken, forHTTPHeaderField: "Authorization")
        
            let body = ["emoji" : emoji, "text" : text]
            let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        
            request.httpMethod = "POST"
            request.httpBody = bodyData

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Set Status failed: \(error)")
                    completion(false)
                } else if let data = data {
                    let result = try? JSONDecoder().decode(SetStatusResponse.self, from: data)
                    if let res = result {
                        if res.message != "Status set." {
                            print("Set Status API, error returned: \(res.message)")
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else {
                    print("Set Status failed API failed")
                    completion(false)
                }
            }
            task.resume()
        }
    }
}

private extension WebService {
    func networkRequest<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, requestBody: [String : AnyObject]?, completion: @escaping (T?, NetworkingError?) -> Void) {
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
                if let data = data {
                    do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                        completion(result, nil)
                        return
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
