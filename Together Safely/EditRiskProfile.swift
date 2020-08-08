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
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Risk Profile")
                .font(Font.custom("Avenir-Heavy", size: 40))
//                .padding(.leading, 5)
//                .padding(.trailing, 5)
                .foregroundColor(Color.white)
                .padding(.leading, 30)

            List {
                ForEach (questions, id: \.id) { question in
                    RiskQuestionItem(question: question)
                }
            }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding(20)
            Button(action: {
//                get answers from data source
//                WebService.postQuestionAnswers(answers: <#T##[UserAnswer]#>, completion: <#T##(Bool) -> Void#>)
            }) {
                HStack {
                    Spacer()
                     Image("accept")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                }
                    .padding(.trailing, 20)
                    .padding(.top, 35)
            }
            Spacer()
        }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Image("backgroudImage").edgesIgnoringSafeArea(.all))
        .onAppear() {
            self.firebaseService.getRiskFactorQuestions() { results in
                self.questions = results
                
            }
        }
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

struct RiskQuestionItem: View {
    let question: UserQuestion
    @State var selectedIndex: Int = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(question.text).multilineTextAlignment(.leading).padding([.top, .bottom], 15.0)
            Picker(selection: $selectedIndex, label: Text(question.text)) {
                Text("Yes").tag(0)
                Text(" - ").tag(1)
                Text("No").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
        }.onAppear() {
            switch self.question.userResponse {
            case nil:
                self.selectedIndex = 1
            case true:
                self.selectedIndex = 0
            case false:
                self.selectedIndex = 2
            case .some(_):
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
