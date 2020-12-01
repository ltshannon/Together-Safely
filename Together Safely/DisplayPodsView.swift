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

    @State private var getRiskColor: Color = Color.white
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var items: FetchedResults<CDRiskRanges>
    
    @FetchRequest(
        entity: CDGroups.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CDGroups.name, ascending: true)]
    ) var groups: FetchedResults<CDGroups>

    var body: some View {

        VStack {
//            if self.isVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    if groups.count > 0 {
                        ForEach((0...groups.count-1), id: \.self) { index in
                            NavigationLink(destination: DetailPodView(groupId: groups[index].groupId ?? "")) {
                                VStack(alignment: .leading, spacing: 0) {
                                    VStack {
                                        HStack {
                                            Text("\(groups[index].name ?? "")")
                                                .font(Font.custom("Avenir-Medium", size: 18))
                                                .padding(.leading, 20)
                                                .foregroundColor(.white)
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .fill(Color("Colorred"))
                                                    .frame(width: 25, height: 25)
                                                Text("\(groups[index].newMessageCnt)")
                                                    .font(.body)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }.padding(.leading, 5).padding(.trailing, 10)
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
                                    if groups[index].riskTotals != nil {
                                        let result = try! JSONDecoder().decode([String: Int].self, from: groups[index].riskTotals ?? Data())
                                        BuildRiskBar(dict: result, memberCount: Int(groups[index].groupCount)).padding(15)
                                    }

                                    Spacer()
                                    Text("Mostly \(groups[index].averageRisk ?? "")")
                                        .font(Font.custom("Avenir-Medium", size: 16))
                                        .foregroundColor(self.getRiskColor.V3GetRiskColor(riskScore: groups[index].averageRiskValue, ranges: items))
                                        .padding(.leading, 15)

                                    Spacer()
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ReadMembersForDisplayView(groupId: groups[index].groupId ?? "")
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
                        DisplayPodsContactPod(groupId: "")
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

