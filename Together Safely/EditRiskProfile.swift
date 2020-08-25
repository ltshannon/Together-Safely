//
//  EditRiskProfile.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/5/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct EditRiskProfile: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var firebaseService: FirebaseService
    @State var questions = [UserQuestion]()
    @State var responses = [UserAnswer]()
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Risk Profile")
                .font(Font.custom("Avenir-Medium", size: 22))
                .foregroundColor(Color.white)

            List {
                ForEach (questions, id: \.id) { question in
                    RiskQuestionItem(question: question) { (questionId, response) in
                        var updatedResponses = [UserAnswer]()
                        for (index, question) in self.questions.enumerated() {
                            if question.id == questionId {
                                let response = UserAnswer(answer: response, userQuestion: question.id ?? "")
                                updatedResponses.append(response)
                            } else {
                                let response = self.responses[index]
                                updatedResponses.append(response)
                            }
                        }
                        self.responses = updatedResponses
                    }
                }
            }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    WebService.postQuestionAnswers(answers: self.responses) { (success) in
                        print("\(success)")
                    }
                }) {
                    HStack {
                        Text("Accept")
                        Image(systemName: "checkmark")
                    }
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 15)
                    .foregroundColor(.white)
                    .background(Color("Color4"))
                    .cornerRadius(8)
                }
            }
            Spacer()
        }
            .padding(15)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Image("backgroudImage").edgesIgnoringSafeArea(.all))
        .onAppear() {
            self.firebaseService.getRiskFactorQuestions() { results in
                self.questions = results
                let mappedResponses = results.map({ (question) -> UserAnswer in
                    return UserAnswer(answer: question.userResponse, userQuestion: question.id ?? "")
                })
                self.responses = mappedResponses
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
}

struct RiskQuestionItem: View {
    let question: UserQuestion
    @State var selectedIndex: Int = 1
    var callback: (String?, Bool?) -> ()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(question.text).multilineTextAlignment(.leading).padding([.top, .bottom], 15.0)
            Picker(selection: $selectedIndex, label: Text(question.text)) {
                Text("Yes").tag(0)
                Text(" - ").tag(1)
                Text("No").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
            .onReceive([self.selectedIndex].publisher) { (value) in
                var response: Bool? = nil
                switch value {
                case 0: response = true
                case 2: response = false
                default: response = nil
                }
                self.callback(self.question.id, response)
            }
        }.onAppear() {
            switch self.question.userResponse {
            case true:
                self.selectedIndex = 0
            case false:
                self.selectedIndex = 2
            default:
                self.selectedIndex = 1
            }
        }
    }
}

struct EditRiskProfile_Previews: PreviewProvider {
    static var previews: some View {
        EditRiskProfile()
    }
}
