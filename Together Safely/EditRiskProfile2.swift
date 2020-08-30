//
//  EditRiskProfile2.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/25/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct EditRiskProfile2: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var firebaseService: FirebaseService
    @State var groups = [QuestionGroups]()
    @State private var arrayIndexs: [Int] = []
    @State var responses: [QuestionGroupsAnswer] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Risk Profile")
                .font(Font.custom("Avenir-Medium", size: 22))
                .foregroundColor(Color.white)
            RiskQuestionItem2(groups: $groups, responses: $responses)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    WebService.postGroupAnswers(answers: self.responses) { (success) in
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
            self.firebaseService.getRiskQuestionGroups() { results in
                self.groups = results
                let answers = QuestionGroupsAnswers(groups: results)
                self.responses = answers.answers
            }
        }
    }
    
    var btnBack : some View {
        Button(action: {
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

struct QuestionsArray {
    var groupIndexs: [Int]
    var questionIds: UUID
}

struct RiskQuestionItem2: View {
    @Binding var groups: [QuestionGroups]
    @Binding var responses: [QuestionGroupsAnswer]
    @State private var arrayIndexs: [Int] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(group.text)
                            .padding([.top, .bottom], 15.0)
                            .font(Font.custom("Avenir Heavy", size: 20))

                        ForEach(Array(group.questions.enumerated()), id: \.offset) { y, question in
                            VStack(alignment: .leading, spacing: 0) {
                                Text(question.text)
                                    .font(Font.custom("Avenir-Medium", size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                ForEach(Array(question.choices.enumerated()), id: \.offset) { i, choice in
                                    HStack {
                                        CheckboxView(
                                            id: self.computeIndex(group: index, question: y, choice: i),
                                            arrayIndexs: self.arrayIndexs,
                                            size: 14,
                                            textSize: 14,
                                            callback: self.checkboxSelected
                                        )

                                        Text(choice.text)
                                            .font(Font.custom("Avenir-Medium", size: 18))
                                    }.padding()
                                        .onAppear() {
                                            if let ans = question.userResponse {
                                                if ans == i {
                                                     print("onappear: question.userResponse: \(question.userResponse ?? 999) i: \(i)")
                                                     if !self.arrayIndexs.contains(self.computeIndex(group: index, question: y, choice: i)) {
                                                         self.arrayIndexs.append(self.computeIndex(group: index, question: y, choice: i))
                                                     }
                                                 }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func computeIndex(group: Int, question: Int, choice: Int) -> Int {
        var id = 0
        var questionNum = 0

        if let i = self.responses.firstIndex(where: {$0.groupNumber == group}) {
            questionNum = question + i
            id = self.responses[questionNum].groupIndexs[choice]
        }
        return id
    }

    func checkboxSelected(id: Int, isMarked: Bool) {
        print("responses: \(responses)")
        print("\(id) is marked: \(isMarked)")
        for array in responses {
            if array.groupIndexs.contains(id) {
                if arrayIndexs.contains(id) {
                    break
                }
                let same = arrayIndexs.same(as: array.groupIndexs)
                for item in same {
                    if let itemIndex = arrayIndexs.firstIndex(of: item) {
                        arrayIndexs.remove(at: itemIndex)
                    }
                }
                arrayIndexs.append(id)
                let questionId = array.questionId
                print("questionId: \(questionId)")
                for (responseIndex, response) in responses.enumerated() {
                    print("response.questionId: \(response.questionId)")
                    if response.questionId == questionId {
                        responses[responseIndex].answer = id % 10
                        for (i, group) in groups.enumerated() {
                            for (index, _) in group.questions.enumerated() {
                                if groups[i].questions[index].id == questionId {
                                    groups[i].questions[index].userResponse = id % 10
                                }
                            }
                        }
                    }
                }
                break
            }
        }
        print("arrayIndexs: \(arrayIndexs)")
    }
}

struct EditRiskProfile2_Previews: PreviewProvider {
    static var previews: some View {
        EditRiskProfile2()
    }
}
