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
    @State private var group: Groups = Groups(id: "", name: "", members: [], riskTotals: [:], riskCompiledSring: [], riskCompiledValue: [], averageRisk: "", averageRiskValue: 0)
    
    var body: some View {
        GeometryReader { metrics in
        VStack {
            VStack {
                ZStack {
                    Capsule()
                        .fill((Color("Color1").opacity(49)))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 35, maxHeight: 35)
                        .padding([.leading, .trailing], 10)
                    
                        HStack {
                            Text("Pods")
                                .font(Font.custom("Avenir-Medium", size: 18))
                                .foregroundColor(self.index == 0 ? .white : .black)
                                .fontWeight(.bold)
                                .padding([.leading, .trailing], 10)
                                .frame(width: metrics.size.width * 0.45)
                                .background(Color("Color3").opacity(self.index == 0 ? 1 : 0))
                                .clipShape(Capsule())
                                .onTapGesture {
                                    withAnimation(.default){
                                        self.index = 0
                                    }
                                }
                            Spacer()
                            HStack {
                                Text("Invitations")
                                    .font(Font.custom("Avenir-Heavy", size: 18))
                                    .foregroundColor(self.index == 1 ? .white : .black)
                                    .fontWeight(.bold)
                                    .padding(.leading, 10)
                                ZStack {
                                    Circle()
                                        .fill(Color("Colorred"))
                                        .frame(width: 18, height: 18)
                                    Text("\(self.firebaseService.invites.count)")
                                        .font(.body)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                }.padding(.leading, 5).padding(.trailing, 10)
                            }
                            .frame(width: metrics.size.width * 0.45)
                            .background(Color("Color3").opacity(self.index == 1 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture { withAnimation(.default){ self.index = 1 } }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 30, maxHeight: 30)
                        .padding([.leading, .trailing], 20)
                    
                }
                Spacer()
                if self.index == 0 {
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
                    DisplayPodsView().environmentObject(self.firebaseService)
                } else {
                    InviationsView().environmentObject(self.firebaseService)
                }
            }
            NavigationLink(destination: UserProfileView().environmentObject(self.firebaseService), tag: 1, selection: self.$action) {
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
                    if self.firebaseService.user.image != nil {
                        Image(uiImage: UIImage(data:self.firebaseService.user.image!)!)
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
