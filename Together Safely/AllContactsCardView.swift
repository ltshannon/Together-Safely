//
//  AllContactsCardView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/4/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts

enum PageType: Int {
    case addContacts
    case addFriends
    case createPod
}

struct AllContactsCardView: View {
    
    var pageType:PageType
    @Binding var name:String
    var group: Groups
    @State var showingAlert = false
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentation
    var webService = WebService()
    @State private var arrayIndexs: [Int] = []
    @State private var members:[String] = []
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
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
                if !firebaseService.userContacts.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(firebaseService.userContacts.indices) { index in
                            VStack {
                                HStack {
                                    ZStack {
                                        if self.firebaseService.userContacts[index].imageData != nil {
                                            Image(uiImage: UIImage(data: self.firebaseService.userContacts[index].imageData!)!)
                                                .resizable()
                                                .renderingMode(.original)
                                                .frame(width: 75, height: 75)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                                .foregroundColor(Color.blue)
                                                .padding(5)
                                        } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color("Color9"), lineWidth: 7))
                                            .foregroundColor(Color.blue)
                                            .padding(.leading, 10)
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(Color("Colorgray"))
                                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                            .offset(x: 30, y: 30)
                                        }
                                    }
                                    .padding(.bottom, 5)
                                    VStack(alignment: .leading) {
                                        Text("\(self.firebaseService.userContacts[index].name)")
                                            .foregroundColor(Color("Colorblack"))
                                            .font(Font.custom("Avenir Next Medium", size: 28))
                                            .padding(.leading, 5)
                                        Text("No risk status")
                                            .foregroundColor(Color("Colorgray"))
                                            .font(Font.custom("Avenir Next Medium", size: 20))
                                            .padding(.leading, 5)
                                    }
                                    Spacer()
                                    if self.pageType == .addContacts {
                                        Button(action: {
                                            self.webService.createInvite(contact: self.firebaseService.userContacts[index]) { successful in
                                                if !successful {
                                                    print("createInvite failed for: \(self.firebaseService.userContacts[index].givenName)")
                                                }
                                                self.presentation.wrappedValue.dismiss()
                                            }
                                        }) {
                                            Image("buttonInvite")
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 50)
                                                .padding(.trailing, 20)
                                        }
                                    } else {
                                        CheckboxView(
                                            id: index,
                                            label: "",
                                            size: 14,
                                            textSize: 14,
                                            callback: self.checkboxSelected
                                        )
                                    }
                                }
                                Capsule()
                                    .fill(Color("Colorgray"))
                                    .frame(height: 1)
                                    .padding(10)
                            }
                        }
                    }
                }
            }
                .frame(width: UIScreen.main.bounds.size.width - 40)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding(5)
            Spacer()
            if pageType == .createPod {
                VStack {
                    Button(action: {
                        if self.name.count < 1 {
                            self.showingAlert = true
                            return
                        }
                        self.webService.createNewGroup(name: self.name, members: self.members) { successful in
                            if !successful {
                                print("createNewGroup failed for: \(self.name)")
                            }
                        }
                        self.presentation.wrappedValue.dismiss()
                    }) {
                    Image("createButton")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text("Pod name must have at least 1 character"), dismissButton: .default(Text("Continue")))
                }
            } else if pageType == .addFriends {
                Button(action: {
                    for member in self.members {
                        self.webService.inviteUserToGroup(groupId: self.group.id, phoneNumber: member) { successful in
                            if !successful {
                                print("inviteUserToGroup failed for: \(member)")
                            }
                        }
                    }
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Image("addButton")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
            }
        }
    }
    
    func checkboxSelected(id: Int, isMarked: Bool) {
        print("\(id) is marked: \(isMarked)")
        if isMarked {
            arrayIndexs.append(id)
        } else {
            if let index = arrayIndexs.firstIndex(of: id) {
                arrayIndexs.remove(at: index)
            }
        }
        members.removeAll()
        
        for index in arrayIndexs {
            for phone in firebaseService.userContacts[index].phoneNumbers {
                if let label = phone.label {
                    if label == CNLabelPhoneNumberMobile {
                        var number = phone.value.stringValue
                        number = format(with: "+1XXXXXXXXXX", phone: number)
                        members.append(number)
                    }
                }
            }
        }
        print("arrayIndexs: \(arrayIndexs)")
        print("members: \(members)")
    }
}
/*
struct CheckboxView: View {
    let id: Int
    let label: String
    let size: CGFloat
    let color: Color
    let textSize: Int
    let callback: (Int, Bool)->()
    
    init(
        id: Int,
        label:String,
        size: CGFloat = 10,
        color: Color = Color.black,
        textSize: Int = 14,
        callback: @escaping (Int, Bool)->()
        ) {
        self.id = id
        self.label = label
        self.size = size
        self.color = color
        self.textSize = textSize
        self.callback = callback
    }
    
    @State var isMarked:Bool = false
    
    var body: some View {
        Button(action:{
            self.isMarked.toggle()
            self.callback(self.id, self.isMarked)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(self.isMarked ? "checkboxOn" : "checkboxOff")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                Text(label)
                    .font(Font.system(size: size))
                Spacer()
            }.foregroundColor(self.color)
        }
        .foregroundColor(Color.white)
    }
}
*/

/*
struct AllContactsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AllContactsCardView(pageType: .addContacts)
    }
}
*/
