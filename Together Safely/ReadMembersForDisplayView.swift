//
//  ReadMembersForDisplayView.swift
//  Together Safely
//
//  Created by Larry Shannon on 11/23/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct ReadMembersForDisplayView: View {
    var groupId: String
    var members: FetchRequest<CDMember>
    
    @FetchRequest(
        entity: CDContactInfo.entity(),
        sortDescriptors: []
    ) var contactInfo: FetchedResults<CDContactInfo>
    
    init(groupId: String) {
        self.groupId = groupId

        members = FetchRequest<CDMember>(entity: CDMember.entity(), sortDescriptors: [], predicate: NSPredicate(format: "groupId == %@", groupId))
        
    }
    
    var body: some View {
        ForEach(members.wrappedValue) { member in
            MemberProfileByIndexView(contacts: contactInfo, phoneNumber: member.phoneNumber ?? "", riskScore: member.riskScore)
        }
    }
}

