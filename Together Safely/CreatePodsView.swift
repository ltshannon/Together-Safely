//
//  CreatePodsView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Firebase

struct CreatePodsView: View {
    
    var webService = WebService()
    @State private var name: String = ""
    @State private var showSuccess = false
    @State private var showFailure = false
    @State private var showingAlert = false
    @State private var code: String = ""
    @State private var id: String = ""
    @State private var alert = false
    @State private var msg = ""

    var body: some View {
        VStack {
            TextField("Enter the pod name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(50)
            Button(action: {
                if self.name.count < 1 {
                    self.showingAlert = true
                    return
                }
                self.id =  UserDefaults.standard.value(forKey: "authVerificationID") as? String ?? ""
                self.code =  UserDefaults.standard.value(forKey: "verificationCode") as? String ?? ""
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.id, verificationCode: self.code)
                
                Auth.auth().signIn(with: credential) { (res, error) in
                    if let error = error {
                        self.msg = error.localizedDescription
                        self.alert.toggle()
                        return
                    }
                    let currentUser = Auth.auth().currentUser
                    currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error {
                            self.msg = error.localizedDescription
                            self.alert.toggle()
                            return;
                        }
                        if let str = idToken {
                            UserDefaults.standard.set(str, forKey: "idToken")
                            UserDefaults.standard.set(true, forKey: "status")
                            self.webService.createNewGroup(name: self.name) { successful in
                                if successful {
                                    self.showSuccess.toggle()
                                } else {
                                    self.showFailure.toggle()
                                }
                            }
                        }
                    }
                }
            }) {
                Text("Create")
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(25)
            }
            
            if showSuccess {
                Text("Success")
            } else if showFailure {
                Text("Failure")
            }
        }
        .navigationBarTitle("")
        .background(Image("backgroudImage").edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text("Pod name must have at least 1 character"), dismissButton: .default(Text("Continue")))
        }
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("ok")))
        }
    }
}

struct CreatePodsView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePodsView()
    }
}
