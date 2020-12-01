//
//  FullMemberProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct FullMemberProfileView: View {

    var member: Member
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    
    @FetchRequest(
        entity: CDContactInfo.entity(),
        sortDescriptors: []
    ) var contactInfo: FetchedResults<CDContactInfo>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var riskRanges: FetchedResults<CDRiskRanges>

    var body: some View {

        HStack {
            MemberProfileByIndexView(contacts: contactInfo, phoneNumber: member.phoneNumber, riskScore: member.riskScore)

            VStack(alignment: .leading, spacing: 5) {
                Text(self.getName(phoneName: member.phoneNumber, contacts: contactInfo))
                Text(member.status.text)
                    .font(Font.custom("Avenir-Medium", size: 14))
                    .foregroundColor(Color("Colorgray"))
                Text(member.riskString)
                    .font(Font.custom("Avenir-Medium", size: 14))
                    .foregroundColor(getRiskColor.V3GetRiskColor(riskScore: member.riskScore, ranges: riskRanges))
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color("Colorred"))
                    .frame(width: 25, height: 25)
                Text("\(member.newMessageCnt)")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()
            Text(member.status.emoji)
            .font(Font.custom("Avenir Next Medium", size: 45))
        }
    }
    
    func getName(phoneName: String, contacts: FetchedResults<CDContactInfo>) -> String {
        
        for item in contacts {
            if item.phoneNumber == phoneName {
                return item.name ?? phoneName
            }
        }
        return phoneName
    }
    
}
