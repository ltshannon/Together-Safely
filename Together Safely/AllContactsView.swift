//
//  AllContactsView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/31/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

struct AllContactsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var contactStore: ContactStore
    var webService = WebService()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack {
                        HStack {
                            Text("All Contacts")
                                .font(Font.custom("Avenir-Heavy", size: 30))
                                .padding(.leading, 20)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "line.horizontal.3.decrease")
                                .font(Font.custom("Avenir-Heavy", size: 35))
                                .padding(.trailing, 20)
                                .foregroundColor(Color.white)
                        }
                    }
                        .frame(height:(75))
                        .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                    Capsule()
                        .fill(Color(.blue))
                        .frame(height: 2)
                        .padding(0)
                    Spacer()
                    if !contactStore.contacts.isEmpty {
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(contactStore.contacts, id: \.self) { contact in
                                VStack {
                                    HStack {
                                        ZStack {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color("Color9"), lineWidth: 7))
                                                .foregroundColor(Color.blue)
                                                .padding(.leading, 10)
                                            Circle()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color("Color12"))
                                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                                .offset(x: 30, y: 30)
                                        }
                                        .padding(.bottom, 5)
                                        VStack(alignment: .leading) {
                                            Text("\(contact.name)")
                                                .foregroundColor(Color("Color11"))
                                                .font(Font.custom("Avenir Next Medium", size: 28))
                                                .padding(.leading, 5)
                                            Text("No risk status")
                                                .foregroundColor(Color("Color10"))
                                                .font(Font.custom("Avenir Next Medium", size: 20))
                                                .padding(.leading, 5)
                                        }
                                        Spacer()
                                        Button(action: {
                                            self.webService.createInvite(contact: contact) { successful in
                                                if successful {
                                                    
                                                } else {
                                                    
                                                }
                                            }
                                        }) {
                                            Image("buttonInvite")
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 50)
                                                .padding(.trailing, 20)
                                        }
                                    }
                                    Capsule()
                                        .fill(Color("Color16"))
                                        .frame(height: 1)
                                        .padding(10)

                                }
                            }
                        }
                    }
                }
                    .frame(width: UIScreen.main.bounds.size.width - 15)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding(5)
                Spacer()
            }
        }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Image("backgroudImage").edgesIgnoringSafeArea(.all))
    }
    
    var btnBack : some View { Button(action: {
          self.presentationMode.wrappedValue.dismiss()
          }) {
              HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
                Text("Pods")
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
              }
          }
      }
}

/*
struct AllContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AllContactsView()
    }
}
*/
