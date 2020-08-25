//
//  InviationsView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/2/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct InviationsView: View {
    
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var getImageForPhone: Data = Data()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                HStack {
                    Text("All Invites")
                        .font(Font.custom("Avenir-Medium", size: 18))
                        .padding(.leading, 20)
                        .foregroundColor(.white)
                    Spacer()
                }.padding([.top, .bottom], 15)
            }
                .background(Color("Color4")).edgesIgnoringSafeArea(.all)
            Capsule()
                .fill(Color(.darkGray))
                .frame(height: 2)
                .padding(0)
            if !firebaseService.invites.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(Array(firebaseService.invites.enumerated()), id: \.offset) { index, invite in
//                    ForEach(firebaseService.invites, id: \.self) { invite in
                        VStack {
                            HStack {
                            MemberProfileView(
                                image: self.getImageForPhone.getImage(phoneName: invite.adminPhone, dict: self.firebaseService.contactInfo),
                                groupId: invite.groupId,
                                riskScore: invite.riskScore,
                                riskRanges: self.firebaseService.riskRanges)
                            VStack(alignment: .leading) {
                                Text(self.firebaseService.getNameForPhone(invite.adminPhone, dict: self.firebaseService.contactInfo))
                                    .foregroundColor(Color("Colorblack"))
                                    .font(Font.custom("Avenir Next Medium", size: 18))
                                Text("invited you to:")
                                    .font(Font.custom("Avenir Next Medium Italic", size: 14))
                                    .foregroundColor(Color("Colorgray"))
                                Text(invite.groupName)
                                    .foregroundColor(Color("Color13"))
                                    .font(Font.custom("Avenir Next Medium", size: 16))
                            }.padding(.trailing, 10)
                            Spacer()
                                VStack {
                                    Button(action: {
                                        WebService.acceptInviteToGroup(groupId: invite.groupId) { successful in
                                            if successful {
                                                print("success")
                                            } else {
                                                print("fail")
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "checkmark")
                                            Text("Accept")
                                        }
                                        .padding([.top, .bottom], 10)
                                        .padding([.leading, .trailing], 5)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color("Color4"))
                                        .cornerRadius(8)
                                    }
                                    Button(action: {
                                        WebService.declineInviteToGroup(groupId: invite.groupId) { successful in
                                            if successful {
                                                
                                            } else {
                                                
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "xmark.circle")
                                            Text("Decline")
                                        }
                                        .padding([.top, .bottom], 10)
                                        .padding([.leading, .trailing], 5)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color("Colorred"))
                                        .cornerRadius(8)
                                    }
                                }.padding(.trailing, 5)
                        }
                        Capsule()
                            .fill(Color("Colorgray"))
                            .frame(height: 1)
                            .padding([.leading, .trailing], 5)
                        }.padding([.leading, .trailing, .top], 10)
                    }
                }
            } else {
                Spacer()
            }
        }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
            .padding(15)
    }
}

struct InviationsView_Previews: PreviewProvider {
    static var previews: some View {
        InviationsView()
    }
}
