//
//  DetailPodView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct DetailPodView: View {
    
    var group: Groups
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var inputStr: String = ""
    @State private var emojiText: String = ""
    @State private var widthArray: Array = []
    @State private var getRiskColor: Color = Color.white
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    if firebaseService.user.image != nil {
                        Image(uiImage: UIImage(data:firebaseService.user.image!)!)
                            .resizable()
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
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .foregroundColor(Color.blue)
                            .padding(5)
                    }
                    HStack {
//                        Capsule()
//                            .fill(Color(.black))
//                            .frame(width: 1, height: 60)
//                            .padding(0)
                        TextFieldWrapperView(text: self.$emojiText)
                            .background(Color.white)
                            .frame(width: 30, height: 30)
                            .font(Font.custom("Avenir Next Medium Italic", size: 40))
//                            .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.gray, lineWidth: 1))
                        TextField("I want to..", text: $inputStr)
                            .font(Font.custom("Avenir Next Medium Italic", size: 30))
                            .foregroundColor(Color("Colorblack"))
                        Button (action: {
                            if self.inputStr.count == 0 {
                                return
                            }
                            WebService.setStatus(text: self.inputStr, emoji: self.emojiText, groupId: self.group.id){ successful in
                                if !successful {
                                    print("Set status failed for groupId : \(self.group.id))")
                                } else {
                                    self.inputStr = ""
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("Colorgray"))
                                .font(Font.custom("Avenir Next Medium", size: 30))
                        }
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.gray, lineWidth: 1))
                    .background(Color.white)
                }
                    .frame(width: UIScreen.main.bounds.size.width - 40)
                HStack {
                    Spacer()
                    NavigationLink(destination: AddFriendView(group: group).environmentObject(self.firebaseService)) {
                        Text("Add Friend")
                            .font(Font.custom("Avenir-Heavy", size: 35))
                            .foregroundColor(.white)
                        Image(systemName: "plus.circle")
//                            .renderingMode(.original)
                            .font(.title)
                            .foregroundColor(.white).opacity(81)
                    }
                }
                 .padding(.trailing, 20)
                VStack(alignment: .leading, spacing: 0) {
                    VStack {
                        HStack {
                            Text(group.name)
                                .font(Font.custom("Avenir-Heavy", size: 25))
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
                    BuildRiskBar(highRiskCount: group.riskTotals["High Risk"] ?? 0, medRiskCount: group.riskTotals["Medium Risk"] ?? 0, lowRiskCount: group.riskTotals["Low Risk"] ?? 0, memberCount: group.members.count).environmentObject(self.firebaseService).padding(15)
                    Spacer()
                    Text(group.averageRisk)
                        .font(Font.custom("Avenir-Heavy", size: 20))
                        .foregroundColor(getRiskColor.getRiskColor(riskScore: group.averageRiskValue, riskRanges: firebaseService.riskRanges))
                        .padding(.leading, 10)
                    Spacer()
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            ForEach(0..<group.members.count) { index in
                                Capsule()
                                    .fill(Color(.gray))
                                    .frame(height: 1)
                                    .padding(10)
                                HStack {
                                    Text("")
                                    
                                    FullMemberProfileView(
                                        groupId: self.group.id,
                                        member: self.group.members[index]).environmentObject(self.firebaseService)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                    .frame(width: UIScreen.main.bounds.size.width - 40)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding(5)
                Spacer()
            }
        }
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
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
                Text("Back")
                    .font(Font.custom("Avenir Next Medium", size: 30))
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
        textField.placeholder = "🙂"
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

/*
struct DetailPodView_Previews: PreviewProvider {
    static var previews: some View {
        DetailPodView()
    }
}
*/
