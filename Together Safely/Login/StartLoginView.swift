//
//  StartLoginView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/20/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct StartLoginView: View {
    @State private var show = false
    private var headerTextSize:CGFloat = 40
    private var bodyTextSize:CGFloat = 22
    @State private var disableButton = false
//    @ObservedObject private var locationFetcher = LocationFetcher()
    @State private var showError = false
//    @EnvironmentObject var locationFetcher: LocationFetcher
    
    var body: some View {
        ZStack {
            Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all)
//            Color("Colorgreen").edgesIgnoringSafeArea(.all)
            VStack {
                Image("start-login-logo")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                Spacer()
                Text("Welcome to Together!")
                    .multilineTextAlignment(.center)
                    .font(Font.custom("Avenir-Black", size: headerTextSize))
                    .foregroundColor(.white)
                Spacer()
                Text("Together lets you socialize safely with friends. Let's get started!")
                    .multilineTextAlignment(.center)
                    .font(Font.custom("Avenir-Medium", size: bodyTextSize))
                    .foregroundColor(.white)
                Spacer()
//                NavigationLink(destination: PhoneLoginView().environmentObject(locationFetcher), isActive: $show) {
                NavigationLink(destination: PhoneLoginView(), isActive: $show) {
                    Button(action: {
                        self.show.toggle()
                    }) {
                    Text("Let's go!")
                        .frame(width: 200, height: 50)
                        .font(Font.custom("Avenir-Black", size: 25))
                    }
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        .disabled(disableButton)
                }
                Spacer()
            }
                .padding(15)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
//                .onAppear() {
//                    self.locationFetcher.start()
//                }
        }
/*
        .alert(isPresented: $locationFetcher.alert) {
            Alert(title: Text("Location service needs to be enable"), message: Text("Please enable location service for this app"), primaryButton: .destructive(Text("Continue to settings")) {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
            }, secondaryButton: .cancel() {
                self.showError.toggle()
            })
        }
*/
    }
}

struct StartLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StartLoginView()
    }
}
