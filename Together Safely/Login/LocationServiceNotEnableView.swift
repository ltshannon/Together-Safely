//
//  LocationServiceNotEnableView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/26/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct LocationServiceNotEnableView: View {
    
    @State private var textSize:CGFloat = 35
    @State private var green = UIColor(hex: "#5AC481ff")
    
    var body: some View {
        ZStack {
            Color(green!).edgesIgnoringSafeArea(.all)
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
                Text("This app can not run")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Text("without Location")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Text("service enabled")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Text("Enable Location service")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Text("and restart the app")
                    .font(Font.custom("Avenir-Black", size: textSize))
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct LocationServiceNotEnableView_Previews: PreviewProvider {
    static var previews: some View {
        LocationServiceNotEnableView()
    }
}
