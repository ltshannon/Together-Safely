//
//  HomeView.swift
//  Together
//
//  Created by Larry Shannon on 7/19/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var index = 0
    @State private var action: Int? = 0
    @State private var group: Groups = Groups(id: "", adminId: "", name: "", members: [], riskTotals: [:], riskCompiledSring: [], riskCompiledValue: [], averageRisk: "", averageRiskValue: 0)
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    Capsule()
                        .fill((Color("Color1").opacity(49)))
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 75)
                    HStack {
                         Text("Pods")
                            .font(Font.custom("Avenir-Heavy", size: 25))
                            .foregroundColor(self.index == 0 ? .white : .black)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color("Color3").opacity(self.index == 0 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture {
                                 withAnimation(.default){
                                     self.index = 0
                                 }
                             }
//                            .padding(.leading, 20)
                        HStack {
                             Text("Invitations")
                                .font(Font.custom("Avenir-Heavy", size: 25))
                                .foregroundColor(self.index == 1 ? .white : .black)
                                .fontWeight(.bold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                            ZStack {
                                Circle()
                                    .fill(Color("Colorred"))
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
                        .frame(width: UIScreen.main.bounds.size.width - 40)
                }
//                    .padding(.horizontal)
//                    .padding(.top,25)
//                    .padding(.leading, 50)
//                    .padding(.trailing, 50)
                Spacer()
                if index == 0 {
                    NavigationLink(destination: CreatePodView().environmentObject(self.firebaseService)) {
                        HStack {
                            Spacer()
                            Text("Create Pod")
                                .font(Font.custom("Avenir-Heavy", size: 35))
                                .foregroundColor(.white)
                            Image(systemName: "plus.circle")
                                .font(.title)
                                .foregroundColor(.white).opacity(81)
                        }
                         .padding(.trailing, 20)
                    }
                    Spacer()
                    DisplayPodsView().environmentObject(firebaseService)
                } else {
                    InviationsView().environmentObject(firebaseService)
                }
            }
            NavigationLink(destination: UserProfileView().environmentObject(firebaseService), tag: 1, selection: $action) {
                EmptyView()
            }
        }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                HStack {
                    Button(action: {
                        self.action = 1
                    }) {
                        if firebaseService.user.image != nil {
                            Image(uiImage: UIImage(data:firebaseService.user.image!)!)
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .padding(5)
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .foregroundColor(Color.blue)
                                .padding(5)
                        }
                    }
                    Text("")
                        .frame(width: 40, height: 10)
                    HeaderView()
                }
            )
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
