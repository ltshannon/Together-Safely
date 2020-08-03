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
    var contactStore: ContactStore
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var membersArray: [Int] = []
    @State var memberRiskColor: Color = Color.gray
    @State var selection: Int? = nil
/*
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
*/
    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
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
                                            .foregroundColor(Color.gray)
                                    }
                                }
                                    .frame(height:(75))
                                    .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                                Capsule()
                                    .fill(Color(.blue))
                                    .frame(height: 2)
                                    .padding(0)
                                Spacer()
                                HStack {
                                    ForEach(0..<group.riskCompiledSring.count) { index in
                                        VStack {
                                            Text("\(group.riskCompiledSring[index])")
                                                .font(Font.custom("Avenir-Heavy", size: 20))
                                                .padding(.leading, 10)
                                            Text("\(group.riskCompiledValue[index])")
                                                .font(Font.custom("Avenir-Heavy", size: 20))
                                                .padding(.leading, 10)
                                        }
                                    }
                                }
                                Spacer()
                                Text(group.averageRisk)
                                    .font(Font.custom("Avenir-Heavy", size: 20))
                                    .padding(.leading, 10)
                                Spacer()
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<group.members.count) { index in
                                            MemberProfileView(riskScore: group.members[index].riskScore, riskRanges: self.firebaseService.riskRanges)
                                        }
                                    }
                                }
                                Spacer()
                            }
                                .frame(width: UIScreen.main.bounds.size.width - 15, height: 300)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                .padding(5)
                        }
                    }
                    Spacer()
                    VStack {
                        NavigationLink(destination: AllContactsView(contactStore: contactStore), tag: 2, selection: $selection) {
                            Button(action: {
                                self.selection = 2
                            }) {
                                VStack(alignment: .leading, spacing: 0) {
                                    VStack {
                                        HStack {
                                            Text("All Contacts")
                                                .font(Font.custom("Avenir-Heavy", size: 25))
                                                .padding(.leading, 20)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(Font.custom("Avenir-Heavy", size: 20))
                                                .padding(.trailing, 20)
                                                .foregroundColor(Color.gray)
                                        }
                                    }
                                        .frame(height:(75))
                                        .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                                    Capsule()
                                        .fill(Color(.blue))
                                        .frame(height: 2)
                                        .padding(0)
                                    Spacer()
                                    List(contactStore.contacts, id: \.self) { (contact: CNContact) in
                                        if contact.imageDataAvailable {
                                            Image(uiImage: UIImage(data: contact.imageData!)!)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color(.white), lineWidth: 1))
                                                    .frame(width: 75.0, height: 75.0)
                                        }
                                        Text("\(contact.name)")
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 15, height: 300)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            }
                    }
                }
            }
        }
    }
}
/*
struct DisplayPodsView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayPodsView()
    }
}
*/
