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
                    Text(question.text)
                }
            }
            .frame(width: UIScreen.main.bounds.size.width - 40, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding(20)
            Button(action: {
            
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

struct EditRiskProfile_Previews: PreviewProvider {
    static var previews: some View {
        EditRiskProfile()
    }
}
