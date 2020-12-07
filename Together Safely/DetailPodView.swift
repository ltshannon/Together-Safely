//
//  DetailPodView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct DetailPodView: View {
    
    var groupId: String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var inputStr: String = ""
    @State private var emojiText: String = ""
    @State private var widthArray: Array = []
    @State private var getRiskColor: Color = Color.white
    @State private var showingChildView = false
    @State private var phoneNumbers: [String] = []
    var group: FetchRequest<CDGroups>
    var members: FetchRequest<CDMember>
    let context = DataController.appDelegate.persistentContainer.viewContext
    
    @FetchRequest(
        entity: CDUser.entity(),
        sortDescriptors: []
    ) var user: FetchedResults<CDUser>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var items: FetchedResults<CDRiskRanges>
    
    init(groupId: String) {
        self.groupId = groupId

        group = FetchRequest<CDGroups>(entity: CDGroups.entity(), sortDescriptors: [], predicate: NSPredicate(format: "groupId == %@", groupId))
        
        members = FetchRequest<CDMember>(entity: CDMember.entity(),
                                         sortDescriptors: [NSSortDescriptor(keyPath: \CDMember.phoneNumber, ascending: true)],
                                         predicate: NSPredicate(format: "groupId == %@", groupId))
        
    }
    
    var body: some View {

        VStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if user.first?.image != nil {
                            Image(uiImage: UIImage(data: (user.first?.image!)!)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                .padding([.top, .bottom], 5)

                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .padding([.top, .bottom], 5)
                        }
                        Text("My daily status:")
                            .font(Font.custom("Avenir-Medium", size: 22))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Select:")
                            .foregroundColor(Color.white)
                            .font(Font.custom("Avenir-Medium", size: 15))
                            .padding(.top, 15)
                            .padding(.bottom, 10)
                        HStack {
                            TextFieldWrapperView(text: self.$emojiText)
                                .background(Color.white)
                                .frame(width: 30, height: 30)
                                .padding(5)
                                .cornerRadius(20)
                                .background(Color.white)

                            TextField("e.g. let's meet for coffee", text: $inputStr)
                                .frame(height: 30)
                                .font(Font.custom("AvenirNext-Italic", size: 18))
                                .foregroundColor(Color("Colorblack"))
                                .padding(5)
                                .background(Color.white)

                            Button (action: {
                                if self.inputStr.count == 0 {
                                    return
                                }
                                WebService.setStatus(text: self.inputStr, emoji: self.emojiText, groupId: group.wrappedValue.first?.groupId ?? ""){ successful in
                                    if !successful {
                                        print("Set status failed for groupId : \(group.wrappedValue.first?.groupId ?? ""))")
                                    } else {
                                        self.inputStr = ""
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.black)
                                    .font(Font.custom("Avenir-Medium", size: 18))
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    if user.first?.id == group.wrappedValue.first?.adminId ?? "" {
                        NavigationLink(destination: AddFriendView(groupId: group.wrappedValue.first?.groupId ?? "")) {
                            Text("Add Friend")
                                .font(Font.custom("Avenir-Medium", size: 22))
                                .foregroundColor(.white)
                            Image(systemName: "plus.circle")
                                .font(Font.system(size: 22))
                                .foregroundColor(.white)
                        }
                    } else {
                        Spacer()
                    }
                }.padding(.top, 20)
                    .padding(.bottom, 5)
                VStack(alignment: .leading, spacing: 0) {
                    VStack {
                        HStack {
                            Text(group.wrappedValue.first?.name ?? "")
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
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()

                        if group.wrappedValue.first?.riskTotals != nil {
                            let result = try! JSONDecoder().decode([String: Int].self, from: group.wrappedValue.first?.riskTotals ?? Data())
                            BuildRiskBar(dict: result, memberCount: Int(group.wrappedValue.first?.groupCount ?? 0) ).padding(15)
                        }
                        Spacer()
                        Text("Mostly \(group.wrappedValue.first?.averageRisk ?? "")")
                            .font(Font.custom("Avenir-Medium", size: 16))
                            .foregroundColor(self.getRiskColor.V3GetRiskColor(riskScore: group.wrappedValue.first?.averageRiskValue ?? 0, ranges: items))
                            .padding(.leading, 15)
                    }
                    .frame(height: 75)
                    .padding(.bottom, 15)
//                    ScrollView(.vertical, showsIndicators: false) {
//                        VStack(alignment: .leading, spacing: 5) {
                    ReadMembersForDetailView(groupId: groupId, adminId: group.wrappedValue.first?.adminId ?? "")
//                        }
//                    }
                    NavigationLink(destination: DetailMemberView(title: group.wrappedValue.first?.name ?? "", groupId: groupId, phoneNumber: phoneNumbers, members: members),
                                   isActive: self.$showingChildView)
                    { EmptyView() }
                        .frame(width: 0, height: 0)
                        .disabled(true)
                }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
            }

        }
            .padding([.leading, .trailing, .bottom], 15)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack, trailing: btnDetail)
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
        .onAppear() {
            phoneNumbers.removeAll()
            for member in members.wrappedValue {
                if let number = member.phoneNumber {
                    print(number)
                    phoneNumbers.append(number)
                }
            }
        }
        .onDisappear() {
            group.wrappedValue.first?.newMessageCnt = 0
            
            do {
                try context.save()
            }
            catch {
                print("error writing members: \(error.localizedDescription)")
            }
        }
    }
    
    var btnBack : some View { Button(action: {
          self.presentationMode.wrappedValue.dismiss()
          }) {
            HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .font(Font.custom("Avenir-Medium", size: 18))
                    .foregroundColor(.white)
                Text("Back")
                    .font(Font.custom("Avenir-Medium", size: 18))
                    .foregroundColor(.white)
            }
          }
    }
 
    var btnDetail : some View { Button(action: {
        self.showingChildView = true
        }) {
            HStack {
//                Text("Details")
//                    .font(Font.custom("Avenir-Medium", size: 18))
//                    .foregroundColor(.white)
                Image(systemName: "text.bubble")
                    .aspectRatio(contentMode: .fit)
                    .font(Font.custom("Avenir-Medium", size: 25))
                    .foregroundColor(.white)
                    .padding(.top, 18)
            }
        }
    }

}

struct TextFieldWrapperView: UIViewRepresentable {

    @Binding var text: String

    func makeCoordinator() -> TFCoordinator {
        TFCoordinator(self)
    }
}

extension TextFieldWrapperView {

    func makeUIView(context: UIViewRepresentableContext<TextFieldWrapperView>) -> UITextField {
        let textField = EmojiTextField()
        textField.delegate = context.coordinator
        textField.placeholder = "☕️"
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textField.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(textField.doneButtonTapped(button:)))
        toolBar.items = [doneButton]
        toolBar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolBar
        return textField
    }


    func updateUIView(_ uiView: UITextField, context: Context) {

    }
}

class TFCoordinator: NSObject, UITextFieldDelegate {
    var parent: TextFieldWrapperView

    init(_ textField: TextFieldWrapperView) {
        self.parent = textField
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let value = textField.text {
            if value.count > 0 {
                textField.text = ""
            }
            parent.text = string
//            parent.onChange?(value)
        }
        return true
    }

}

class EmojiTextField: UITextField {

    // required for iOS 13
    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}

struct CustomTextfield: UIViewRepresentable {
    @Binding var text: String
    var keyType: UIKeyboardType
    var placeHolder: String
    func makeUIView(context: Context) -> UITextField {
        let textfield = UITextField()
        textfield.keyboardType = keyType
        textfield.placeholder = placeHolder
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textfield.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(textfield.doneButtonTapped(button:)))
        toolBar.items = [doneButton]
        toolBar.setItems([doneButton], animated: true)
        textfield.inputAccessoryView = toolBar
        return textfield
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

}

extension  UITextField{
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }
    
    @objc func NextButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }
    
}
