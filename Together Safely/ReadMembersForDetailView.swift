//
//  ReadMembersForDetailView.swift
//  Together Safely
//
//  Created by Larry Shannon on 11/23/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct ReadMembersForDetailView: View {
    var groupId: String
    var members: FetchRequest<CDMember>
    
    init(groupId: String) {
        self.groupId = groupId

        members = FetchRequest<CDMember>(entity: CDMember.entity(),
                                         sortDescriptors: [NSSortDescriptor(keyPath: \CDMember.memberName, ascending: true)],
                                         predicate: NSPredicate(format: "groupId == %@", groupId))
    }
    
    var body: some View {
        
        ForEach((0...members.wrappedValue.count-1), id: \.self) { index in
            Capsule()
                .fill(Color(.gray))
                .frame(height: 1)
                .padding(.top, 5)
                HStack {
                    FullMemberProfileView(member: makeMember(member: members.wrappedValue[index]))
                }
                .padding([.leading, .trailing], 15)
        }
    }
    
    func makeMember(member: CDMember) -> Member {
        
        let m = Member(id: member.groupId ?? "", adminId: member.adminId ?? "", phoneNumber: member.phoneNumber ?? "", riskScore: member.riskScore, status: Status(emoji: member.emoji ?? "", text: member.textString ?? ""), riskString: member.riskString ?? "", riskIndex: Int(member.riskIndex), memberName: member.memberName ?? "", newMessageCnt: Int(member.newMessageCnt))
        
        return m
        
    }
}
