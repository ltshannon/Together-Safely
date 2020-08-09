//
//  SpinnerView.swift
//  Together
//
//  Created by Larry Shannon on 7/19/20.
//

import SwiftUI

struct SpinnerView: View {
    
    @State private var textSize:CGFloat = 35
    @State private var animate = true
    
    var body: some View {
        ZStack {
            Color("Colorgreen").edgesIgnoringSafeArea(.all)
            VStack {
                Image("start-login-logo")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                Spacer()
                VStack {
                Circle()
                    .trim()
                    .stroke(AngularGradient(gradient: .init(colors: [.white, .green]), center:  .center), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 125, height: 125)
                    .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                    .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
                }
                .padding(20)
                .background(Color("Colorgreen"))
                .cornerRadius(15)
                .onAppear {
                    self.animate.toggle()
                }
                Spacer()
                Spacer()
                Spacer()
            }
//              .navigationTitle("")
//               .navigationBarHidden(true)
//               .navigationBarBackButtonHidden(true)
        }
    }
}

struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerView()
    }
}
