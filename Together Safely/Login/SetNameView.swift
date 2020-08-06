//
//  SetNameView.swift
//  Together
//
//  Created by Larry Shannon on 7/18/20.
//

import SwiftUI
import Combine


struct SetNameView: View {
    
    @State private var show = false
    @State private var alert = false
    @State private var showIndicator = false
    @State private var msg = ""
    @State private var name: String = ""
    @State private var textSize:CGFloat = 35
    @State private var keyboardHeight: CGFloat = 0
    @State private var service = WebService()
    
    var body: some View {
        ZStack {
            Color("Colorgreen").edgesIgnoringSafeArea(.all)
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
                Group {
                    Text("Set your name/")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                    Text("nickname")
                        .font(Font.custom("Avenir-Black", size: textSize))
                        .foregroundColor(.white)
                }
                Spacer()
//                TextField("Display name", text: $name)
                CustomTextField("Display name", value: $name, keyType: .alphabet)
                    .frame(width: 300, height: 25)
                    .font(Font.custom("Avenir-Black", size: 25))
                    .padding()
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, keyboardHeight)
                    .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
                Spacer()
                NavigationLink(destination: DummyView(), isActive: $show) {
                    Button(action: {
                        if self.name.count == 0 {
                            self.msg = "Please enter a name"
                            self.alert.toggle()
                            return
                        }
                        UserDefaults.standard.set(self.name, forKey: "username")
                        self.service.createUser { (successful: Bool) in
                            self.showIndicator.toggle()
                            if !successful {
                                self.msg = "Creating user failed"
                                self.alert.toggle()
                                return
                            }
                            self.show.toggle()
                        }
                        self.showIndicator.toggle()
                    }) {
                        Text("Continue")
                            .frame(width: 200, height: 50)
                            .font(Font.custom("Avenir-Black", size: 25))
                    }
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                Spacer()
            }
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("ok")))
            }
            if self.showIndicator {
                GeometryReader {geometry in
                    SpinnerView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
    
    func createUser() {
        
        let service = WebService()
        
        service.createUser { (competion: Bool) in
            
        }
        
    }
}

struct SetNameView_Previews: PreviewProvider {
    static var previews: some View {
        SetNameView()
    }
}
