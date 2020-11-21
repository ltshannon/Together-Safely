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
    let groupId: String
    let index: Int
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    var members: FetchRequest<CDMember>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var items: FetchedResults<CDRiskRanges>

    init(contacts: FetchedResults<CDContactInfo>, groupId: String, index: Int) {
        self.contacts = contacts
        self.groupId = groupId
        self.index = index

        members = FetchRequest<CDMember>(entity: CDMember.entity(), sortDescriptors: [], predicate: NSPredicate(format: "groupId == %@", groupId))
        
    }
    
    var body: some View {
        ZStack {
            let image = self.getImageForPhone.newGetImage(phoneName: members.wrappedValue.count > index ? members.wrappedValue[index].phoneNumber ?? "" : "", contacts: contacts)
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
                .foregroundColor(getRiskColor.V3GetRiskColor(riskScore: members.wrappedValue.count > index ? members.wrappedValue[index].riskScore : 0, ranges: items))
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .offset(x: 25, y: 25)
        }
        .padding(.bottom, 5)
    }
    
}

