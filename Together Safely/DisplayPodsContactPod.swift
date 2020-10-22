//
//  DisplayPodsContactPod.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/6/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

struct DisplayPodsContactPod: View {
    
    var group: Groups
    @State var selection: Int? = nil
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    
    var body: some View {
        VStack {
            NavigationLink(destination: AllContactsView(group: group).environmentObject(firebaseService), tag: 2, selection: $selection) {
                Button(action: {
                    self.selection = 2
                }) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack {
                            HStack {
                                Text("All Contacts")
                                    .font(Font.custom("Avenir-Medium", size: 18))
                                    .padding(.leading, 20)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(Font.custom("Avenir-Medium", size: 18))
                                    .padding(.trailing, 20)
                                    .foregroundColor(.white)
                            }.padding([.top, .bottom], 15)
                        }
                            .background(Color("Color4")).edgesIgnoringSafeArea(.all)
                        Capsule()
                            .fill(Color(.darkGray))
                            .frame(height: 2)
                            .padding(0)
//                        BuildRiskBar(highRiskCount: firebaseService.userContantRiskAverageDict["High Risk"] ?? 0, medRiskCount: firebaseService.userContantRiskAverageDict["Medium Risk"] ?? 0, lowRiskCount: firebaseService.userContantRiskAverageDict["Low Risk"] ?? 0, memberCount: firebaseService.userContantUsersCount).environmentObject(self.firebaseService).padding(15)
                        BuildRiskBar(dict: firebaseService.userContantRiskAverageDict, memberCount: firebaseService.userContantUsersCount).environmentObject(self.firebaseService).padding(15)
                        Spacer()
                        Text(firebaseService.userContantRiskAverageString)
                            .font(Font.custom("Avenir-Medium", size: 16))
                            .foregroundColor(self.getRiskColor.getRiskColor(riskScore: firebaseService.userContantRiskAverageValue, firebaseService: self.firebaseService))
                            .padding(.leading, 15)
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(firebaseService.userContacts) { item in
//                                    if item.type == .userPhoneNumber {
                                        MemberProfileView(
                                            image: self.getImageForPhone.getImage(phoneName: item.phoneNumber, dict: self.firebaseService.contactInfo),
                                            groupId: "",
                                            riskScore: item.riskScore != nil ? item.riskScore! : 0,
                                            riskRanges: self.firebaseService.riskRanges)
//                                    }
                                }
                            }
                        }.padding(.leading, 5)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding([.leading, .trailing], 15)
                    .padding(.bottom, 5)
                }
            }
        }
    }
}

/*
struct DisplayPodsContactPod_Previews: PreviewProvider {
    static var previews: some View {
        DisplayPodsContactPod()
    }
}
*/
