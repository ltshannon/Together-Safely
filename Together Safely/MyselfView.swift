//
//  MyselfView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/21/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct MyselfView: View {
//    var contactStore: ContactStore
    @EnvironmentObject var dataController: DataController
    @State private var image = "\u{1F600}".image()
    @State var index = 0
    
    var body: some View {
        ZStack {
            Color("Colorgreen").edgesIgnoringSafeArea(.all)
            VStack {
                HeaderView()
                ZStack {
                    Capsule()
                        .fill(Color("Color"))
                        .frame(width: UIScreen.main.bounds.size.width - 15, height: 75)
                    HStack {
                         Text("Pods")
                            .font(Font.custom("Avenir-Heavy", size: 25))
                            .foregroundColor(self.index == 0 ? .white : .black)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .background(Color("Color3").opacity(self.index == 0 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture {
                                 withAnimation(.default){
                                     self.index = 0
                                 }
                             }
                            .padding(.leading, 5)
                         Text("Invitations")
                            .font(Font.custom("Avenir-Heavy", size: 25))
                            .foregroundColor(self.index == 1 ? .white : .black)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .background(Color("Color3").opacity(self.index == 1 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture {
                                 withAnimation(.default){
                                     self.index = 1
                                 }
                             }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color("Colorred"))
                                .frame(width: 45, height: 45)
                            Text("3")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                        }
                            .padding(.trailing, 5)
                    }
                }
                 .padding(.horizontal)
                 .padding(.top,25)
                Spacer()
                HStack {
                    Spacer()
                    Text("Create Pod")
                        .font(Font.custom("Avenir-Heavy", size: 35))
                        .foregroundColor(.white)
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.white).opacity(81)
                }
                 .padding(.trailing, 35)
                Spacer()
                DisplayPodsView().environmentObject(dataController)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    func makeuiImage(str: String) -> UIImage {
        print(str)
        
        if let img = str.image() {
            return img
        }
        
        return "\u{1F600}".image()!
    }
}
/*
struct MyselfView_Previews: PreviewProvider {
    static var previews: some View {
        MyselfView()
    }
}
*/

