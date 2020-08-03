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
    var webService: WebService = WebService()
    
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
                            MemberProfileView(riskScore: invite.riskScore, riskRanges: self.firebaseService.riskRanges)
                            VStack(alignment: .leading) {
//                                Text(invite.adminName)
                                Text("Name")
                                    .foregroundColor(Color("Color15"))
                                    .font(Font.custom("Avenir Next Medium", size: 25))
                                    .padding(.leading, 5)
                                Text("invited you to:")
                                    .font(Font.custom("Avenir Next Medium Italic", size: 20))
                                    .foregroundColor(Color("Color12"))
                                Text(invite.groupName)
                                    .foregroundColor(Color("Color13"))
                                    .font(Font.custom("Avenir Next Medium", size: 20))
                                    .padding(.trailing, 5)
                            }
                            Spacer()
                            Button(action: {
                                self.webService.acceptInviteToGroup(groupId: invite.groupId) { successful in
                                    if successful {
                                        
                                    } else {
                                        
                                    }
                                }
                            }) {
                                Image("accept")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                                    .padding(.trailing, 20)
                            }
                        }
                        Capsule()
                            .fill(Color("Color16"))
                            .frame(height: 1)
                            .padding(10)
                        }

                    }
                }
            }
        }
            .frame(width: UIScreen.main.bounds.size.width - 15)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
            .padding(5)
    }
}

struct InviationsView_Previews: PreviewProvider {
    static var previews: some View {
        InviationsView()
    }
}
