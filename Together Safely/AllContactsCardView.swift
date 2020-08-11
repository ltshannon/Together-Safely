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
    @State private var str: String = ""
    
    var body: some View {
        VStack {
            Spacer()
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
                                                .overlay(Circle().stroke(
                                                    self.firebaseService.userContacts[index].riskScore != nil ?
                                                    self.riskColor.getRiskColor(riskScore: self.firebaseService.userContacts[index].riskScore!, riskRanges: self.firebaseService.riskRanges) :
                                                    Color("Colorgray")
                                                    , lineWidth: 2))
                                                .padding(5)
                                        } else {
                                            Image(systemName: "person.crop.circle.fill")
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
                                        if self.firebaseService.userContacts[index].riskString != nil {
                                            Text(self.firebaseService.userContacts[index].riskString!)
                                                .foregroundColor(self.riskColor.getRiskColor(riskScore: self.firebaseService.userContacts[index].riskScore!, riskRanges: self.firebaseService.riskRanges))
                                                .font(Font.custom("Avenir-Medium", size: 14))
                                                .padding(.leading, 5)
                                        } else {
                                            Text(self.firebaseService.userContacts[index].phoneNumber.applyPatternOnNumbers(pattern: "###-###-####", replacmentCharacter: "#"))
                                                .foregroundColor(Color("Colorblack"))
                                                .font(Font.custom("Avenir-Medium", size: 12))
                                            Text("No risk status")
                                            .foregroundColor(Color("Colorgray"))
                                            .font(Font.custom("Avenir-Medium", size: 15))
                                                Spacer()
                                        }
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
                .padding([.leading, .trailing, .bottom], 15)
            if pageType == .createPod {
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
                    HStack {
                        Text("Add")
                        Image(systemName: "checkmark")
                    }
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 15)
                    .foregroundColor(.white)
                    .background(Color("Color3"))
                    .cornerRadius(8)
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
struct AllContactsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AllContactsCardView(pageType: .addContacts)
    }
}
*/
