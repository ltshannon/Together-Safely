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
                                    .font(Font.custom("Avenir-Medium", size: 18))
                                    .padding(.leading, 20)
                                    .foregroundColor(.white)
                                Spacer()
                            }.padding([.top, .bottom], 15)
                        }
                            .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                        Capsule()
                            .fill(Color(.darkGray))
                            .frame(height: 2)
                            .padding(0)

                        List(firebaseService.userContacts, id: \.self) { (contact: TogetherContactType) in
                            if contact.contactInfo.imageDataAvailable {
                                Image(uiImage: UIImage(data: contact.contactInfo.imageData!)!)
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                    .padding(5)
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .padding([.top, .bottom], 5)
                            }
                            Text("\(contact.contactInfo.name)")
                                .foregroundColor(Color("Colorblack"))
                                .font(Font.custom("Avenir-Medium", size: 18))
                        }.frame(height: 300)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding([.leading, .trailing], 15)
                    .padding(.bottom, 5)
                }
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
