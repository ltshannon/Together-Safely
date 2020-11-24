//
//  HomeView.swift
//  Together
//
//  Created by Larry Shannon on 7/19/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var index = 0
    @State private var action: Int? = 0
    
    @FetchRequest(
        entity: CDUser.entity(),
        sortDescriptors: []
    ) var user: FetchedResults<CDUser>
    
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
                                    .font(Font.custom("Avenir-Medium", size: 18))
                                    .foregroundColor(self.index == 1 ? .white : .black)
                                    .fontWeight(.bold)
                                    .padding(.leading, 10)
                                ZStack {
                                    Circle()
                                        .fill(Color("Colorred"))
                                        .frame(width: 18, height: 18)
                                    Text("\(dataController.invites.count)")
                                        .font(.body)
                                        .fontWeight(.bold)
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
                    
                }.padding(.top, 15)
                Spacer()
                if self.index == 0 {
                    NavigationLink(destination: CreatePodView()) {
                        HStack {
                            Spacer()
                            Text("Create Pod")
                                .font(Font.custom("Avenir-Medium", size: 22))
                                .foregroundColor(.white)
                            Image(systemName: "plus.circle")
                                .font(Font.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 15)
                    }
                    Spacer()
                    DisplayPodsView()
                } else {
                    InviationsView().environmentObject(dataController)
                }
            }
            NavigationLink(destination: UserProfileView(), tag: 1, selection: self.$action) {
                EmptyView()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            HStack {
                Button(action: {
                    self.action = 1
                }) {
                    if user.first?.image != nil {
                        Image(uiImage: UIImage(data: (user.first?.image!)!)!)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding([.top, .bottom], 5)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding([.top, .bottom], 5)
                    }
                }
                HeaderView()
                    .padding(.leading, (metrics.size.width / 2.0) - CGFloat(HeaderView.width))//130 is the width of the header view
            }
        )
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
