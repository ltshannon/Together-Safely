//
//  HomeView.swift
//  Together
//
//  Created by Larry Shannon on 7/19/20.
//

import SwiftUI

struct HomeView: View {
    var contactStore: ContactStore
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var image = "\u{1F600}".image()
    @State var index = 0
    
    var body: some View {
        VStack {
            VStack {
                HeaderView()
                ZStack {
                    Capsule()
                        .fill((Color("Color1").opacity(49)))
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
                        HStack {
                             Text("Invitations")
                                .font(Font.custom("Avenir-Heavy", size: 25))
                                .foregroundColor(self.index == 1 ? .white : .black)
                                .fontWeight(.bold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 25)
                            ZStack {
                                Circle()
                                    .fill(Color("Color4"))
                                    .frame(width: 45, height: 45)
                                Text("\(firebaseService.invites.count)")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                            }
                                .padding(.trailing, 5)
                        }
                            .background(Color("Color3").opacity(self.index == 1 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture { withAnimation(.default){ self.index = 1 } }
                    }
                }
                    .padding(.horizontal)
                    .padding(.top,25)
                Spacer()
                if index == 0 {
                    NavigationLink(destination: CreatePodsView()) {
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
                    }
                    Spacer()
                    DisplayPodsView(contactStore: contactStore).environmentObject(firebaseService)
                } else {
                    InviationsView().environmentObject(firebaseService)
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
*/
