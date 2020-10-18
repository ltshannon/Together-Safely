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
    var riskScore: Double
    var riskRanges: [Dictionary<String,RiskHighLow>]
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var getRiskColor: Color = Color.white
    
    var body: some View {
        ZStack {
            if image != nil {
                Image(uiImage: UIImage(data: image!)!)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
                    .padding(5)

            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.gray)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                    .padding([.top, .bottom], 5)
            }
            Circle()
                .frame(width: 25, height: 25)
                .foregroundColor(getRiskColor.getRiskColor(riskScore: riskScore, firebaseService: self.firebaseService))
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .offset(x: 25, y: 25)
        }
        .padding(.bottom, 5)
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
