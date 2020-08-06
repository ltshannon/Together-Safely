//
//  PhoneVerificationView.swift
//  Together
//
//  Created by Larry Shannon on 7/17/20.
//

import SwiftUI
import Combine
import Firebase

struct PhoneVerificationView: View {
    
    @Binding var id: String
    @State private var show = false
    @State private var code: String = ""
    @State private var msg = ""
    @State private var alert = false
    @State private var textSize:CGFloat = 35
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color("Colorgreen").edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("together")
                    .font(Font.custom("Avenir-Heavy", size: 50))
                    .foregroundColor(.white)
                }
                Spacer()
                Group {
                    Text("Enter the verification")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                    Text("code")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                }
                Spacer()
                CustomTextField("Code", value: $code, keyType: .numberPad)
                    .frame(width: 300, height: 25)
                    .font(Font.custom("Avenir-Black", size: 25))
                    .padding()
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .multilineTextAlignment(TextAlignment.center)
                    .padding(.bottom, keyboardHeight)
                    .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
                Spacer()
                NavigationLink(destination: SetNameView(), isActive: $show) {
                    Button(action: {
                        UserDefaults.standard.set(self.code, forKey: "verificationCode")
                        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.id, verificationCode: self.code)
                        
                        Auth.auth().signIn(with: credential) { (res, error) in
                            if let error = error {
                                self.msg = error.localizedDescription
                                self.alert.toggle()
                                return
                            }
                            if let authData = res {
                                let user = authData.user
                                UserDefaults.standard.set(user.phoneNumber, forKey: "userPhoneNumber")
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
                                    self.show.toggle()
                                    return
                                }
                                
                                self.msg = "Problem creating login"
                                self.alert.toggle()
                            }
                        }
                    }) {
                        Text("Verify")
                            .frame(width: 200, height: 50)
                            .font(Font.custom("Avenir-Black", size: 25))
                    }
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(10)
                }
//                .navigationTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                Spacer()
/*
                Button(action: {}) {
                    Text("")
                    .frame(width: 10, height: 100)
                    .padding(.bottom, keyboardHeight)
                    .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
                    .hidden()
                }
*/
            }
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("ok")))
            }
        }
    }
}
