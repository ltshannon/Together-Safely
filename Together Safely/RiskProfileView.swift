//
//  RiskProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 10/18/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct RiskProfileView: View {
    let imageSize: CGFloat = 100
    @State private var selectedIsolated = false
    @State private var selectedModerate = false
    @State private var selectedActive = false
    @State private var showingAlert = false
    @State private var action = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Set Attitude")
                        .font(Font.custom("Avenir-Heavy", size: 30))
                        .foregroundColor(Color.white)
                        .padding([.leading, .trailing, .bottom], 15)
                    Spacer()
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("What's your attitude these days?")
                    .font(Font.custom("Avenir-Heavy", size: 22))
                    .padding([.leading, .top], 20)
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        self.selectedIsolated = true
                        self.selectedModerate = false
                        self.selectedActive = false
                    }) {
                        HStack {
                            Image(selectedIsolated ? "riskProfileIsolatedOn" : "riskProfileIsolatedOff")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: imageSize, height: imageSize)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Isolated")
                                    .font(Font.custom("Avenir-Heavy", size: 22))
                                Text("\"I'm mostly staying at home\"")
                                    .font(Font.custom("AvenirNext-Italic", size: 18))
                            }
                            .foregroundColor(selectedIsolated ? Color.blue : Color.black)
                                .padding(.leading, 15)
                        }
                            .padding(15)
                    }
                    Button(action: {
                        self.selectedIsolated = false
                        self.selectedModerate = true
                        self.selectedActive = false
                    }) {
                        HStack {
                            Image(selectedModerate ? "riskProfileModerateOn" : "riskProfileModerateOff")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: imageSize, height: imageSize)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Moderate")
                                    .font(Font.custom("Avenir-Heavy", size: 22))
                                Text("\"I like to go-out every so often\"")
                                    .font(Font.custom("AvenirNext-Italic", size: 18))
                            }
                                .foregroundColor(selectedModerate ? Color.blue : Color.black)
                                .padding(.leading, 15)
                        }
                            .padding(15)
                    }
                    Button(action: {
                        self.selectedIsolated = false
                        self.selectedModerate = false
                        self.selectedActive = true
                    }) {
                        HStack {
                            Image(selectedActive ? "riskProfileActiveOn" : "riskProfileActiveOff")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: imageSize, height: imageSize)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Active")
                                    .font(Font.custom("Avenir-Heavy", size: 22))
                                Text("\"I'm out and about living my life\"")
                                    .font(Font.custom("AvenirNext-Italic", size: 18))
                            }
                                .foregroundColor(selectedActive ? Color.blue : Color.black)
                                .padding(.leading, 15)
                        }
                        .padding(15)
                    }
                }
                    .padding([.top, .bottom], 20)
            }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding([.leading, .trailing, .bottom], 15)
            Spacer()
            HStack {
                Spacer()
                NavigationLink(destination: DummyView(), isActive: $action) {
                Button(action: {
                    self.showingAlert = !selectedIsolated && !selectedModerate && !selectedActive
                    if !self.showingAlert {
                        WebService.riskScore(score: selectedIsolated ? 5 : selectedModerate ? 15 : selectedActive ? 25 : 0) { (success) in
                            UserDefaults.standard.set(true, forKey: "attitudeQuestion")
                            action.toggle()
                        }
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
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Question is not completed"), message: Text("Please set your attitude to start the App"), dismissButton: .default(Text("Continue")))
                }
                }
            }
            .padding(15)
            Spacer()
        }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
    }
}

struct RiskProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RiskProfileView()
    }
}
