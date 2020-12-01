//
//  MemberProfileByIndexView.swift
//  Together Safely
//
//  Created by Larry Shannon on 11/18/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct MemberProfileByIndexView: View {
    var contacts: FetchedResults<CDContactInfo>
    let phoneNumber: String
    let riskScore: Double
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
//    var members: FetchRequest<CDMember>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var riskRanges: FetchedResults<CDRiskRanges>
    
    var body: some View {
        ZStack {
            let image = self.getImageForPhone.newGetImage(phoneName: phoneNumber, contacts: contacts)
            if image != nil {
                Image(uiImage: UIImage(data: image!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .renderingMode(.original)
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
                .foregroundColor(getRiskColor.V3GetRiskColor(riskScore: riskScore, ranges: riskRanges))
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .offset(x: 25, y: 25)
        }
        .padding(.bottom, 5)
    }
    
}

