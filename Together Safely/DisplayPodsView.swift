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
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var membersArray: [Int] = []
    @State var memberRiskColor: Color = Color("Colorgray")
    @State var group: Groups = Groups(id: "", name: "", members: [], riskTotals: [:], riskCompiledSring: [], riskCompiledValue: [], averageRisk: "", averageRiskValue: 0)

    var body: some View {

        VStack {
            if !firebaseService.groups.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(firebaseService.groups, id: \.self) { group in
                        NavigationLink(destination: DetailPodView(group: group).environmentObject(self.firebaseService)) {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack {
                                    HStack {
                                        Text("\(group.name)")
                                            .font(Font.custom("Avenir-Heavy", size: 25))
                                            .padding(.leading, 20)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(Font.custom("Avenir-Heavy", size: 20))
                                            .padding(.trailing, 20)
                                            .foregroundColor(Color("Colorgray"))
                                    }
                                }
                                    .frame(height:(75))
                                    .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                                Capsule()
                                    .fill(Color(.blue))
                                    .frame(height: 2)
                                    .padding(0)
                                Spacer()
                                BuildRiskBar(array: self.getWidths(group: group, width: 200))
                                Spacer()
                                Text(group.averageRisk)
                                    .font(Font.custom("Avenir-Heavy", size: 20))
                                    .foregroundColor(self.getColor(riskScore: group.averageRiskValue))
                                    .padding(.leading, 10)
                                Spacer()
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<group.members.count) { index in
                                            MemberProfileView(
                                                image: self.getImage(phoneName: group.members[index].phoneNumber, dict: self.firebaseService.contactInfo),
                                                groupId: group.id,
                                                riskScore: group.members[index].riskScore,
                                                riskRanges: self.firebaseService.riskRanges)
                                        }
                                    }
                                }
                                Spacer()
                            }
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: 300)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                .padding(5)
                        }
                    }
                    Spacer()
                    VStack {
                        DisplayPodsContactPod(group: group).environmentObject(self.firebaseService)
                    }
                }
            } else {
                Spacer()
            }
        }
    }

    func getWidths(group: Groups, width: CGFloat) -> [CGFloat] {
//    func getWidth(forColor: String, listOfRisks: [String], totalRisk: [String : Int], width: CGFloat) -> CGFloat {
        
        var total: Int = 0
        var array: [CGFloat] = [0, 0, 0]
        
        for element in group.riskCompiledSring
        {
            total += Int(group.riskTotals[element]!)
        }
        
        for (_, str) in group.riskCompiledSring.enumerated() {
            
            if total > 0 {
                if let colorValue = group.riskTotals[str] {

                    let v = CGFloat((Int(width) / total) * colorValue)
                    
                    switch str {
                    case "High Risk":
                        array[0] = v
                    case "Medium Risk":
                        array[1] = v
                    case "Low Risk":
                        array[2] = v
                    default:
                        print("error")
                    }
                }
            }
        }
        
        return array
    }
    
    func getImage(phoneName: String, dict: [[String:ContactInfo]]) -> Data? {
        
        for d in dict {
            if d[phoneName] != nil {
                return(d[phoneName]!.image)
            }
        }
        return nil
    }
    
    func getColor(riskScore: Int) -> Color {
        
        for riskRange in firebaseService.riskRanges {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if riskScore >= min && riskScore <= max {
                    for key in riskRange.keys {
                        switch key {
                        case "Low Risk":
                            return Color("riskLow")
                        case "Medium Risk":
                            return Color("riskMed")
                        case "High Risk":
                            return Color("riskHigh")
                        default:
                            return Color("Colorgray")
                        }
                    }
                }
            }
        }
        return Color("Colorgray")
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
