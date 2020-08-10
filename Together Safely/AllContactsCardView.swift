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
    @State private var arrayIndexs: [Int] = []
    @State private var members:[String] = []
    @State private var riskColor: Color = Color.white
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
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
                if !firebaseService.userContacts.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(firebaseService.userContacts.indices) { index in
                            VStack {
                                HStack {
                                    ZStack {
                                        if self.firebaseService.userContacts[index].contactInfo.imageData != nil {
                                            Image(uiImage: UIImage(data: self.firebaseService.userContacts[index].contactInfo.imageData!)!)
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
                                    }
                                    VStack(alignment: .leading) {
                                        Text("\(self.firebaseService.userContacts[index].contactInfo.name)")
                                            .foregroundColor(Color("Colorblack"))
                                            .font(Font.custom("Avenir-Medium", size: 18))
                                        Text(self.firebaseService.userContacts[index].riskString != nil ? self.firebaseService.userContacts[index].riskString! : "No risk status")
                                                .foregroundColor(self.firebaseService.userContacts[index].riskScore != nil ? self.riskColor.getRiskColor(riskScore: self.firebaseService.userContacts[index].riskScore!, riskRanges: self.firebaseService.riskRanges) : Color("Colorgray"))
                                            .font(Font.custom("Avenir-Medium", size: 14))
                                            .padding(.leading, 5)
                                    }
                                    Spacer()
                                    if self.pageType == .addContacts {
                                        if self.firebaseService.userContacts[index].type == .invitablePhoneNumber {
                                            Button(action: {
                                                WebService.createInvite(contact: self.firebaseService.userContacts[index].contactInfo) { successful in
                                                    if !successful {
                                                        print("createInvite failed for: \(self.firebaseService.userContacts[index].contactInfo.givenName)")
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
                            }.padding([.leading, .trailing], 15)
                        }
                    }.padding(.top, 15)
                }
            }
                .frame(minHeight: 300, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding([.leading, .trailing], 15)
            Spacer()
            if pageType == .createPod {
                VStack {
                    Button(action: {
                        if self.name.count < 1 {
                            self.showingAlert = true
                            return
                        }
                        WebService.createNewGroup(name: self.name, members: self.members) { successful in
                            if !successful {
                                print("createNewGroup failed for: \(self.name)")
                            }
                        }
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Create")
                            Image(systemName: "checkmark")
                        }
                        .padding([.top, .bottom], 10)
                        .padding([.leading, .trailing], 15)
                        .foregroundColor(.white)
                        .background(Color("Color3"))
                        .cornerRadius(8)
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text("Pod name must have at least 1 character"), dismissButton: .default(Text("Continue")))
                }
            } else if pageType == .addFriends {
                Button(action: {
                    for member in self.members {
                        WebService.inviteUserToGroup(groupId: self.group.id, phoneNumber: member) { successful in
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
            for phone in firebaseService.userContacts[index].contactInfo.phoneNumbers {
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
