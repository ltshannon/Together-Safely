//
//  DisplayPodsView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/30/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

struct DisplayPodsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var membersArray: [Int] = []
    @State var memberRiskColor: Color = Color("Colorgray")
    @State var group: Groups = Groups(id: "", adminId: "", name: "", members: [], riskTotals: [:], riskCompiledSring: [], riskCompiledValue: [], averageRisk: "", averageRiskValue: 0)
    @State private var widthArray: Array = []
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    @State private var isVisible = false
    
    var body: some View {

        VStack {
//            if self.isVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    if !dataController.groups.isEmpty {
                        ForEach(Array(dataController.groups.enumerated()), id: \.offset) { index, group in
                            NavigationLink(destination: DetailPodView(index: index).environmentObject(dataController)) {
                                VStack(alignment: .leading, spacing: 0) {
                                    VStack {
                                        HStack {
                                            Text("\(group.name)")
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
//                                    BuildRiskBar(highRiskCount: group.riskTotals["High Risk"] ?? 0, medRiskCount: group.riskTotals["Medium Risk"] ?? 0, lowRiskCount: group.riskTotals["Low Risk"] ?? 0, memberCount: group.members.count).environmentObject(self.dataController).padding(15)
                                    BuildRiskBar(dict: group.riskTotals, memberCount: group.members.count).environmentObject(dataController).padding(15)
                                    Spacer()
                                    Text("Mostly \(group.averageRisk)")
                                        .font(Font.custom("Avenir-Medium", size: 16))
                                        .foregroundColor(self.getRiskColor.newGetRiskColor(riskScore: group.averageRiskValue, ranges: dataController.riskRanges))
                                        .padding(.leading, 15)
                                    Spacer()
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(Array(group.members.enumerated()), id: \.offset) { index, element in
//                                            ForEach(0..<group.members.count) { index in
                                                MemberProfileView(
                                                    image: self.getImageForPhone.getImage(phoneName: group.members[index].phoneNumber, dict: dataController.contactInfo),
                                                    groupId: group.id,
                                                    riskScore: group.members[index].riskScore,
                                                    riskRanges: dataController.riskRanges)
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
                    Spacer()
                    VStack {
                        DisplayPodsContactPod(group: group).environmentObject(self.dataController)
                    }
                }.padding(.bottom, 15)
//            } else {
//                Spacer()
//            }
        }.onAppear() {
//            self.isVisible = true
        }.onDisappear() {
//            self.isVisible = false
        }
    }
    
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}
/*
struct DisplayPodsView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayPodsView()
    }
}
*/
