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

    @State private var membersArray: [Int] = []
    @State var memberRiskColor: Color = Color("Colorgray")
    @State var group: Groups = Groups(id: "", adminId: "", name: "", members: [], riskTotals: [:], riskCompiledSring: [], riskCompiledValue: [], averageRisk: "", averageRiskValue: 0)
    @State private var widthArray: Array = []
    @State private var getRiskColor: Color = Color.white
    @State private var isVisible = false
    @State private var result: [String: Int] = [:]
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var items: FetchedResults<CDRiskRanges>
    
    @FetchRequest(
        entity: CDGroups.entity(),
        sortDescriptors: []
    ) var cdGroups: FetchedResults<CDGroups>

    var body: some View {

        VStack {
//            if self.isVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    if cdGroups.count > 0 {
                        ForEach(Array(cdGroups.enumerated()), id: \.offset) { index, group in
                            NavigationLink(destination: DetailPodView(groupId: group.groupId ?? "")) {
                                VStack(alignment: .leading, spacing: 0) {
                                    VStack {
                                        HStack {
                                            Text("\(group.name ?? "")")
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
                                    if group.riskTotals != nil {
                                        let result = try! JSONDecoder().decode([String: Int].self, from: group.riskTotals ?? Data())
                                        BuildRiskBar(dict: result, memberCount: Int(group.groupCount)).padding(15)
                                    }

                                    Spacer()
                                    Text("Mostly \(group.averageRisk ?? "")")
                                        .font(Font.custom("Avenir-Medium", size: 16))
                                        .foregroundColor(self.getRiskColor.V3GetRiskColor(riskScore: group.averageRiskValue, ranges: items))
                                        .padding(.leading, 15)

                                    Spacer()
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ReadMembersForDisplayView(groupId: group.groupId ?? "")
/*
                                            ForEach(0..<Int(group.groupCount)) { index in
                                                MemberProfileByIndexView(contacts: contactInfo, groupId: group.groupId ?? "", index: index)
                                            }
*/
                                        }
                                    }
                                        .padding(.leading, 5)
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
                        DisplayPodsContactPod(group: group)
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
