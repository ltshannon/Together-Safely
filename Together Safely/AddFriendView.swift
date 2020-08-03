//
//  AddFriendView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/2/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Firebase

struct AddFriendView: View {
    var group: Groups
    var webService = WebService()
    @State private var phoneNumber: String = ""
    @State private var showSuccess = false
    @State private var showFailure = false
    @State private var showingAlert = false
    @State private var code: String = ""
    @State private var id: String = ""
    @State private var alert = false
    @State private var msg = ""

    var body: some View {
        VStack {
            TextField("Enter phone number of friend", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(50)
            Button(action: {
                if self.phoneNumber.count < 1 {
                    self.showingAlert = true
                    return
                }
                self.webService.inviteUserToGroup(groupId: self.group.id, phoneNumber: self.phoneNumber)
                    { successful in
                        if successful {
                            self.showSuccess.toggle()
                        } else {
                            self.showFailure.toggle()
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

/*
struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView()
    }
}
*/
