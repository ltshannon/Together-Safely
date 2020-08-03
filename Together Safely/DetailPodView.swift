//
//  DetailPodView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct DetailPodView: View {
    
    var group: Groups
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    NavigationLink(destination: AddFriendView(group: group)) {
                        Text("Add Friend")
                            .font(Font.custom("Avenir-Heavy", size: 35))
                            .foregroundColor(.white)
                        Image(systemName: "plus.circle")
//                            .renderingMode(.original)
                            .font(.title)
                            .foregroundColor(.white).opacity(81)
                    }
                }
                 .padding(.trailing, 35)
                VStack(alignment: .leading, spacing: 0) {
                    VStack {
                        HStack {
                            Text(group.name)
                                .font(Font.custom("Avenir-Heavy", size: 25))
                                .padding(.leading, 20)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "line.horizontal.3.decrease")
                                .font(Font.custom("Avenir-Heavy", size: 35))
                                .padding(.trailing, 20)
                                .foregroundColor(Color.white)
                        }
                    }
                        .frame(height:(75))
                        .background(Color("Color3")).edgesIgnoringSafeArea(.all)
                    Capsule()
                        .fill(Color(.blue))
                        .frame(height: 2)
                        .padding(0)
                    Spacer()
                    HStack {
                        ForEach(0..<group.riskCompiledSring.count) { index in
                            VStack {
                                Text("\(self.group.riskCompiledSring[index])")
                                    .font(Font.custom("Avenir-Heavy", size: 20))
                                    .padding(.leading, 10)
                                Text("\(self.group.riskCompiledValue[index])")
                                    .font(Font.custom("Avenir-Heavy", size: 20))
                                    .padding(.leading, 10)
                            }
                        }
                    }
                    Spacer()
                    Text(group.averageRisk)
                        .font(Font.custom("Avenir-Heavy", size: 20))
                        .padding(.leading, 10)
                    Spacer()
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            ForEach(0..<group.members.count) { index in
                                Capsule()
                                    .fill(Color(.gray))
                                    .frame(height: 1)
                                    .padding(10)
                                HStack {
                                    FullMemberProfileView(riskScore: self.group.members[index].riskScore, riskString: self.group.members[index].riskString, statusText: self.group.members[index].status.text, emoji: self.group.members[index].status.emoji, riskRanges: self.firebaseService.riskRanges)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                    .frame(width: UIScreen.main.bounds.size.width - 15)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding(5)
                Spacer()
            }
        }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
    }
    
    var btnBack : some View { Button(action: {
          self.presentationMode.wrappedValue.dismiss()
          }) {
              HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
                Text("Pods")
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
              }
          }
      }
}
/*
struct DetailPodView_Previews: PreviewProvider {
    static var previews: some View {
        DetailPodView()
    }
}
*/
