//
//  MemberProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/31/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct MemberProfileView: View {
    
    var image: Data?
    var groupId: String
    @EnvironmentObject var firebaseService: FirebaseService
    var riskScore: Int
    var riskRanges: [Dictionary<String,RiskHighLow>]
//    var image: Data
    
    var body: some View {
        ZStack {
            if image != nil {
                Image(uiImage: UIImage(data: image!)!)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
                    .foregroundColor(Color.blue)
                    .padding(5)

            } else {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("Colorgreen"), lineWidth: 7))
                .foregroundColor(Color.blue)
                .padding(5)
            Circle()
                .frame(width: 25, height: 25)
                .foregroundColor(getColor(riskScore: riskScore))
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .offset(x: 25, y: 25)
            }
        }
        .padding(.bottom, 5)
    }
    
    func getColor(riskScore: Int) -> Color {
        
        for riskRange in riskRanges {
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

/*
struct MemberProfileView_Previews: PreviewProvider {
    
    var riskColor: Color = Color.Colorred
    
    static var previews: some View {

        MemberProfileView(riskColor: riskColor)
    }
}
*/
