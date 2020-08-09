//
//  DisplayPodsContactPod.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/6/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

struct DisplayPodsContactPod: View {
    
    var group: Groups
    @State var selection: Int? = nil
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
        VStack {
            NavigationLink(destination: AllContactsView(group: group).environmentObject(firebaseService), tag: 2, selection: $selection) {
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
                                    .foregroundColor(Color("Colorgray"))
                            }
                        }
                            .frame(height:(75))
                            .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                        Capsule()
                            .fill(Color(.blue))
                            .frame(height: 2)
                            .padding(0)
                        Spacer()

                        List(firebaseService.userContacts, id: \.self) { (contact: TogetherContactType) in
                            if contact.contactInfo.imageDataAvailable {
                                Image(uiImage: UIImage(data: contact.contactInfo.imageData!)!)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(.white), lineWidth: 1))
                                    .frame(width: 75, height: 75)
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.blue)
                            }
                            Text("\(contact.contactInfo.name)")
                            Spacer()
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width - 40, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
            }
        }
    }
}

/*
struct DisplayPodsContactPod_Previews: PreviewProvider {
    static var previews: some View {
        DisplayPodsContactPod()
    }
}
*/
