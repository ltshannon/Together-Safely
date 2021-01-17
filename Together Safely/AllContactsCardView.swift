//
//  AllContactsCardView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/4/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Contacts
import CoreData

enum PageType: Int {
    case addContacts
    case addFriends
    case createPod
}

struct AllContactsCardView: View {
    
    var pageType:PageType
    @Binding var name: String
    let groupId: String
    @State var showingAlert = false
    @State var showingAlert2 = false
    @State var showingAlert3 = false
    @State var showingAlert4 = false
    @State var showingAlert5 = false
    @State var showingAlert6 = false
    @State private var showIndicator = false
    @State private var errorString = ""
    @Environment(\.presentationMode) var presentation
    @State private var arrayIndexs: [Int] = []
    @State private var members:[String] = []
    @State private var riskColor: Color = Color.white
    @State private var str: String = ""
    @State private var filteredItems: [TogetherContactType] = []
    @State private var filterString = ""
    @State private var userContacts: [TogetherContactType] = []
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var items: FetchedResults<CDRiskRanges>
    
    @FetchRequest(
        entity: CDContactInfo.entity(),
        sortDescriptors: []
    ) var itemsContacts: FetchedResults<CDContactInfo>
    
    @FetchRequest(
        entity: CDUser.entity(),
        sortDescriptors: []
    ) var user: FetchedResults<CDUser>
    
    init(pageType: PageType, name: Binding<String>, groupId: String) {
        self.pageType = pageType
        self._name = name
        self.groupId = groupId
    }
    
    var body: some View {
        ZStack {
        VStack {
            TextField("Search", text: $filterString.onChange(applyFilter))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .alert(isPresented: $showingAlert6) {
                    Alert(title: Text("Invite sent"), message: Text(errorString), dismissButton: .default(Text("Ok")))
                }
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
                .background(Color("Color4")).edgesIgnoringSafeArea(.all)
                Capsule()
                    .fill(Color(.darkGray))
                    .frame(height: 2)
                    .padding(0)
                    .alert(isPresented: $showingAlert2) {
                        Alert(title: Text("Error sending invite"), message: Text(errorString), dismissButton: .default(Text("Ok")))
                    }
                List {
                    ForEach(Array(self.filteredItems.enumerated()), id: \.offset) { index, element in
                        VStack {
                            HStack {
                                ZStack {
                                    if element.imageData != nil {
                                        Image(uiImage: UIImage(data: element.imageData!)!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
//                                            .renderingMode(.original)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(
                                                element.riskScore != nil ? riskColor.V3GetRiskColor(riskScore: element.riskScore ?? 0, ranges: items) :
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
                                    Text("\(element.name)")
                                        .foregroundColor(Color("Colorblack"))
                                        .font(Font.custom("Avenir-Medium", size: 18))
                                    if element.riskString != nil {
                                        Text(element.riskString!)
                                            .foregroundColor(riskColor.V3GetRiskColor(riskScore: element.riskScore ?? 0, ranges: items))
                                            .font(Font.custom("Avenir-Medium", size: 14))
                                            .padding(.leading, 5)
                                    } else {
                                        Text(element.phoneNumber.applyPatternOnNumbers(pattern: "###-###-####", replacmentCharacter: "#"))
                                            .foregroundColor(Color("Colorblack"))
                                            .font(Font.custom("Avenir-Medium", size: 12))
                                        Text("Unknown Mood")
                                        .foregroundColor(Color("Colorgray"))
                                        .font(Font.custom("Avenir-Medium", size: 15))
                                            Spacer()
                                    }
                                }
                                Spacer()
                                if self.pageType == .addContacts {
                                    if self.filteredItems[index].type == .invitablePhoneNumber {
                                        Button(action: {
                                            showIndicator.toggle()
                                            WebService.createInvite(phoneNumber: element.phoneNumber) { successful, error in
                                                showIndicator.toggle()
                                                if !successful {
                                                    print("createInvite failed for: \(element.name)")
                                                    if let error = error {
                                                        switch error {
                                                        case .serverError(let msg):
                                                            errorString = msg
                                                            showingAlert2 = true
                                                        default:
                                                            errorString = ""
                                                        }
                                                    }
                                                } else {
                                                    changeContactType(phoneNumber: element.phoneNumber)
                                                    showingAlert6 = true
                                                }
//                                                self.presentation.wrappedValue.dismiss()
                                            }
                                        }) {
                                            Image("buttonInvite")
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 50)
//                                                .padding(.trailing, 20)
                                        }
                                    }
                                } else {
                                    CheckboxView(
                                        id: index,
                                        arrayIndexs: self.arrayIndexs,
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
                                    .alert(isPresented: $showingAlert5) {
                                        Alert(title: Text("Error, can not create pod"), message: Text("Pod must have at least one member"), dismissButton: .default(Text("Continue")))
                                    }
                        }
//                            .padding([.leading, .trailing], 15)
                    }
                }
                .onAppear {
                    convertCDContactInfo()
                    applyFilter()
                    UITableView.appearance().separatorStyle = .none
                }
//                    .padding([.leading, .trailing, .bottom, .top], 15)
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
                    if self.members.count == 0 {
                        self.showingAlert5 = true
                        return
                    }
                    WebService.createNewGroup(name: self.name, members: self.members) { successful, error in
                        if !successful {
                            print("createNewGroup failed for: \(self.name)")
                            if let error = error {
                                switch error {
                                case .serverError(let msg):
                                    errorString = msg
                                    showingAlert3 = true
                                default:
                                    errorString = ""
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.presentation.wrappedValue.dismiss()
                            }
                        }
                    }
//                    self.presentation.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text("Create")
                        Image(systemName: "checkmark")
                    }
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 15)
                    .foregroundColor(.white)
                    .background(Color("Color4"))
                    .cornerRadius(8)
                    .alert(isPresented: $showingAlert3) {
                        Alert(title: Text("Error creating new group"), message: Text(errorString), dismissButton: .default(Text("Ok")))
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text("Pod name must have at least 1 character"), dismissButton: .default(Text("Continue")))
                }
            } else if pageType == .addFriends {
                Button(action: {
                    for member in self.members {
                        WebService.inviteUserToGroup(groupId: self.groupId, phoneNumber: member) { successful, error in
                            if !successful {
                                print("inviteUserToGroup failed for: \(member)")
                                if let error = error {
                                    switch error {
                                    case .serverError(let msg):
                                        errorString = msg
                                        showingAlert4 = true
                                    default:
                                        errorString = ""
                                    }
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.presentation.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
//                    self.presentation.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text("Add")
                        Image(systemName: "checkmark")
                    }
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 15)
                    .foregroundColor(.white)
                    .background(Color("Color4"))
                    .cornerRadius(8)
                }
                .alert(isPresented: $showingAlert4) {
                    Alert(title: Text("Error adding user"), message: Text(errorString), dismissButton: .default(Text("Ok")))
                }
            }
        }
        if self.showIndicator {
            GeometryReader {geometry in
                SpinnerView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        }
    }
    
    func changeContactType(phoneNumber: String) {
        for (index, contact) in userContacts.enumerated() {
            if contact.phoneNumber == phoneNumber {
                let c = TogetherContactType(name: contact.name, type: .invitedPhoneNumber, phoneNumber: contact.phoneNumber , imageData: contact.imageData ?? nil, riskScore: contact.riskScore, riskString: contact.riskString ?? "")
                userContacts.remove(at: index)
                userContacts.append(c)
                break
            }
        }
        applyFilter()

        let context = DataController.appDelegate.persistentContainer.viewContext
/*
        let contacts = CDContactInfo(context: context)
        contacts.

        let fetchRequest = FetchRequest<CDContactInfo>(
                    entity: CDContactInfo.entity(),
                    sortDescriptors: [],
                    predicate: NSPredicate(format: "phoneNumber == %@", phoneNumber)
                )
        
        print(fetchRequest.wrappedValue)
*/
        
        let fetchRequest: NSFetchRequest<CDContactInfo> = CDContactInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        if let result = try? context.fetch(fetchRequest) {
            if result.count == 1 {
                print("\(result[0].name ?? "") \(result[0].phoneNumber ?? "")")
                result[0].type = 1
                do {
                    try context.save()
                }
                catch {
                    print("error writing CDContactInfo: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func applyFilter() {
        let cleanedFilter = filterString.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedFilter.isEmpty {
            filteredItems = userContacts.sorted(by: {$0.name < $1.name})
        } else {
            arrayIndexs.removeAll()
            members.removeAll()
            filteredItems = userContacts.filter { element in
                element.name.localizedCaseInsensitiveContains(cleanedFilter)
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
            members.append(filteredItems[index].phoneNumber)
        }
        print("arrayIndexs: \(arrayIndexs)")
        print("members: \(members)")
    }
    
    func convertCDContactInfo() {
        
        let cdUserPhone = user.first?.phoneNumber ?? ""
        userContacts.removeAll()
        
        for item in itemsContacts {
            var addFlag = false
            if let name = item.name, let phoneNumber = item.phoneNumber {
                print("\(name) \(phoneNumber)")
                if cdUserPhone != phoneNumber {
                    addFlag = true
                }
            }
            var type: TogetherContactTypes
            
            switch item.type {
            case 0:
                type = .userPhoneNumber
            case 1:
                type = .invitedPhoneNumber
            case 2:
                type = .invitablePhoneNumber
            default:
                type = .userPhoneNumber
            }
            
            if addFlag {
                let c = TogetherContactType(name: item.name ?? "", type: type, phoneNumber: item.phoneNumber ?? "", imageData: item.imageData ?? nil, riskScore: item.riskScore, riskString: item.riskString ?? "")
                
                userContacts.append(c)
            }
 
        }
        
    }
}
