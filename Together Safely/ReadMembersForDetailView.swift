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
    var adminId: String
    var members: FetchRequest<CDMember>
    @State private var showingAlert = false
    @State private var showingAlert2 = false
    @State private var errorString = ""
    
    init(groupId: String, adminId: String) {
        self.groupId = groupId
        self.adminId = adminId

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
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error deleting user"), message: Text(errorString), dismissButton: .default(Text("Ok")))
                }
            List {
                ForEach(members.wrappedValue, id: \.self) { member in
                    HStack {
                        FullMemberProfileView(member: makeMember(member: member))
                    }
                        .padding([.leading, .trailing], 15)
                }
                    .onDelete(perform: delete)
                    .alert(isPresented:$showingAlert2) {
                        Alert(title: Text("Are you sure you want to delete this pod?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                            WebService.deleteGroup(groupId: groupId){ successful, error in
                                if !successful {
                                    print("Deleting group in ReadMembersForDetailView failed for groupId : \(groupId))")
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
                        }, secondaryButton: .cancel())
                    }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        
        let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
        let userId =  UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        
        if let index = offsets.first {
            if (adminId == userId) && (userPhoneNumber == members.wrappedValue[index].phoneNumber) {
                showingAlert2 = true
            } else {
                if userPhoneNumber == members.wrappedValue[index].phoneNumber {
                    WebService.leaveGroup(groupId: groupId){ successful, error in
                        if !successful {
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
                } else {
                    WebService.removeUser(groupId: groupId, phoneNumber: members.wrappedValue[index].phoneNumber ?? ""){ successful, error in
                        if !successful {
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
    }
    
    func makeMember(member: CDMember) -> Member {
        
        let m = Member(id: member.groupId ?? "", adminId: member.adminId ?? "", phoneNumber: member.phoneNumber ?? "", riskScore: member.riskScore, status: Status(emoji: member.emoji ?? "", text: member.textString ?? ""), riskString: member.riskString ?? "", riskIndex: Int(member.riskIndex), memberName: member.memberName ?? "", newMessageCnt: Int(member.newMessageCnt))
        
        return m
        
    }
}
