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
                    Text("All invites")
                        .font(Font.custom("Avenir-Heavy", size: 25))
                        .padding(.leading, 20)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "line.horizontal.3.decrease")
                        .font(Font.custom("Avenir-Heavy", size: 35))
                        .padding(.trailing, 20)
                        .foregroundColor(Color.white)
                }
            }
                .frame(height:(75))
                .background(Color("Color3")).edgesIgnoringSafeArea(.all)
            Capsule()
                .fill(Color(.blue))
                .frame(height: 2)
                .padding(0)
            Spacer()
            if !firebaseService.groups.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(firebaseService.invites, id: \.self) { invite in
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
                                    .font(Font.custom("Avenir Next Medium", size: 25))
                                    .padding(.leading, 5)
                                Text("invited you to:")
                                    .font(Font.custom("Avenir Next Medium Italic", size: 20))
                                    .foregroundColor(Color("Colorgray"))
                                Text(invite.groupName)
                                    .foregroundColor(Color("Color13"))
                                    .font(Font.custom("Avenir Next Medium", size: 20))
                                    .padding(.trailing, 5)
                            }
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
                                        .padding([.leading, .trailing], 15)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color("Color3"))
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
                                        .padding([.leading, .trailing], 15)
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
                            .padding(10)
                        }
                    }
                }
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
