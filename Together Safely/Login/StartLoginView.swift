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
    @State private var textSize:CGFloat = 35
    @State private var disableButton = false
//    @ObservedObject private var locationFetcher = LocationFetcher()
    @State private var showError = false
    @EnvironmentObject var locationFetcher: LocationFetcher
    
    var body: some View {
        ZStack {
            Color("Color-backgroud").edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("together")
                        .font(Font.custom("Avenir-Heavy", size: 50))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Welcome to")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Text("Together!")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Spacer()
                Group {
                    Text("Together lets you")
                            .font(Font.custom("Avenir-Black", size: textSize))
                            .foregroundColor(.white)
                        Text("socialize safely")
                            .font(Font.custom("Avenir-Black", size: textSize))
                            .foregroundColor(.white)
                        Text("with friends.")
                            .font(Font.custom("Avenir-Black", size: textSize))
                            .foregroundColor(.white)
                        Text("Let's get started!")
                            .font(Font.custom("Avenir-Black", size: textSize))
                            .foregroundColor(.white)
                }
                Spacer()
                NavigationLink(destination: PhoneLoginView().environmentObject(locationFetcher), isActive: $show) {
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
                Group {
                    NavigationLink(destination: LocationServiceNotEnableView(), isActive: $showError) {
                        EmptyView()
                    }
                }
            }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .onAppear() {
                    self.locationFetcher.start()
                }
        }
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
    }
}

struct StartLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StartLoginView()
    }
}
