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
    @State private var showingAlert = false
    @State private var errorString = ""
    
    init(groupId: String) {
        self.groupId = groupId

        members = FetchRequest<CDMember>(entity: CDMember.entity(),
                                         sortDescriptors: [NSSortDescriptor(keyPath: \CDMember.memberName, ascending: true)],
                                         predicate: NSPredicate(format: "groupId == %@", groupId))
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            Capsule()
                .fill(Color(.gray))
                .frame(height: 1)
                .padding(.top, 5)
            List {
                ForEach(members.wrappedValue, id: \.self) { member in
                    HStack {
                        FullMemberProfileView(member: makeMember(member: member))
                    }
                        .padding([.leading, .trailing], 15)
                }
                    .onDelete(perform: delete)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Error deleting user"), message: Text(errorString), dismissButton: .default(Text("Ok")))
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            if let phoneNumber = members.wrappedValue[index].phoneNumber {
        print(offsets.first ?? 99999)
        WebService.removeUser(groupId: groupId, phoneNumber: phoneNumber){ successful, error in
            if !successful {
                print("Leave group in ReadMembersForDetailView failed for groupId : \(groupId))")
                if let error = error {
                    switch error {
                    case .serverError(let msg):
                        errorString = msg
                        showingAlert = true
                    default:
                        errorString = ""
                    }
                }
            } 
        }
            }
        }
    }
    
    func makeMember(member: CDMember) -> Member {
        
        let m = Member(id: member.groupId ?? "", adminId: member.adminId ?? "", phoneNumber: member.phoneNumber ?? "", riskScore: member.riskScore, status: Status(emoji: member.emoji ?? "", text: member.textString ?? ""), riskString: member.riskString ?? "", riskIndex: Int(member.riskIndex), memberName: member.memberName ?? "", newMessageCnt: Int(member.newMessageCnt))
        
        return m
        
    }
}
