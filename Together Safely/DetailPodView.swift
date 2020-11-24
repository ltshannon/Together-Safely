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
    var groups: FetchRequest<CDGroups>
    
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

        groups = FetchRequest<CDGroups>(entity: CDGroups.entity(), sortDescriptors: [], predicate: NSPredicate(format: "groupId == %@", groupId))
        
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
//                                .renderingMode(.original)
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
//                                .font(Font.custom("Avenir-Medium", size: 18))
                                .padding(5)
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
                                .cornerRadius(20)
                                .background(Color.white)

                            TextField("e.g. let's meet for coffee", text: $inputStr)
                                .frame(height: 30)
                                .font(Font.custom("AvenirNext-Italic", size: 18))
                                .foregroundColor(Color("Colorblack"))
                                .padding(5)
//                                .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
//                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray))
                                .background(Color.white)
/*
                            CustomTextfield(text: self.$inputStr, keyType: UIKeyboardType.default, placeHolder: "e.g. let's meet for coffee")
                                .frame(height: 30)
                                .font(Font.custom("AvenirNext-Italic", size: 18))
                                .foregroundColor(Color("Colorblack"))
                                .padding(5)
                                .background(Color.white)
//                                .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
//                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
*/

                            Button (action: {
                                if self.inputStr.count == 0 {
                                    return
                                }
                                WebService.setStatus(text: self.inputStr, emoji: self.emojiText, groupId: groups.wrappedValue.first?.groupId ?? ""){ successful in
                                    if !successful {
                                        print("Set status failed for groupId : \(groups.wrappedValue.first?.groupId ?? ""))")
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
                    if user.first?.id == groups.wrappedValue.first?.adminId ?? "" {
                        NavigationLink(destination: AddFriendView(groupId: groups.wrappedValue.first?.groupId ?? "")) {
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
                            Text(groups.wrappedValue.first?.name ?? "")
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
//                        BuildRiskBar(highRiskCount: self.dataController.groups[index].riskTotals["High Risk"] ?? 0, medRiskCount: self.dataController.groups[index].riskTotals["Medium Risk"] ?? 0, lowRiskCount: self.dataController.groups[index].riskTotals["Low Risk"] ?? 0, memberCount: self.dataController.groups[index].members.count).environmentObject(dataController).padding(15)
//                        BuildRiskBar(dict: self.dataController.groups[index].riskTotals, memberCount: self.dataController.groups[index].members.count).environmentObject(dataController).padding(15)
                        if groups.wrappedValue.first?.riskTotals != nil {
                            let result = try! JSONDecoder().decode([String: Int].self, from: groups.wrappedValue.first?.riskTotals ?? Data())
                            BuildRiskBar(dict: result, memberCount: Int(groups.wrappedValue.first?.groupCount ?? 0) ).padding(15)
                        }
                        Spacer()
                        Text("Mostly \(groups.wrappedValue.first?.averageRisk ?? "")")
                            .font(Font.custom("Avenir-Medium", size: 16))
                            .foregroundColor(self.getRiskColor.V3GetRiskColor(riskScore: groups.wrappedValue.first?.averageRiskValue ?? 0, ranges: items))
                            .padding(.leading, 15)
                    }
                    .frame(height: 75)
                    .padding(.bottom, 15)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 5) {
                            ReadMembersForDetailView(groupId: groups.wrappedValue.first?.groupId ?? "")
/*
                            ForEach(0..<Int(group.groupCount)) { i in
                                Capsule()
                                    .fill(Color(.gray))
                                    .frame(height: 1)
                                    .padding(.top, 5)
                                HStack {
                                    FullMemberProfileView(
                                        groupId: group.groupId ?? "",
                                        index: i)
                                }.padding([.leading, .trailing], 15)
                            }
*/
                        }
                    }
                }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
            }

        }
            .padding([.leading, .trailing, .bottom], 15)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
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
