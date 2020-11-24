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
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    
    @FetchRequest(
        entity: CDRiskAverage.entity(),
        sortDescriptors: []
    ) var risk: FetchedResults<CDRiskAverage>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var riskRanges: FetchedResults<CDRiskRanges>
    
    @FetchRequest(
        entity: CDContactInfo.entity(),
        sortDescriptors: []
    ) var contactInfo: FetchedResults<CDContactInfo>
    
    var body: some View {
        VStack {
            NavigationLink(destination: AllContactsView(groupId: group.id), tag: 2, selection: $selection) {
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
//                        BuildRiskBar(highRiskCount: dataController.userContantRiskAverageDict["High Risk"] ?? 0, medRiskCount: dataController.userContantRiskAverageDict["Medium Risk"] ?? 0, lowRiskCount: dataController.userContantRiskAverageDict["Low Risk"] ?? 0, memberCount: dataController.userContantUsersCount).environmentObject(self.dataController).padding(15)
                        if risk.first?.userContantRiskAverageDict != nil {
                            let result = try! JSONDecoder().decode([String: Int].self, from: risk.first?.userContantRiskAverageDict ?? Data())
                            BuildRiskBar(dict: result, memberCount: Int(risk.first!.userContantUsersCount)).padding(15)
                        }
                        Spacer()
                        Text("Mostly \(risk.first?.userContantRiskAverageString ?? "")")
                            .font(Font.custom("Avenir-Medium", size: 16))
                            .foregroundColor(self.getRiskColor.V3GetRiskColor(riskScore: risk.first?.userContantRiskAverageValue ?? 0, ranges: riskRanges))
                            .padding(.leading, 15)
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(contactInfo) { item in
                                    MemberProfileView(
                                        image: self.getImageForPhone.newGetImage(phoneName: item.phoneNumber ?? "", contacts: contactInfo),
                                        riskScore: item.riskScore)
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
