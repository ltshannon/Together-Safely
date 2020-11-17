//
//  AddFriendView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/2/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI
import Firebase

struct AddFriendView: View {
    var group: Groups
    @State var name:String = ""
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            AllContactsCardView(pageType: .addFriends, name: self.$name, group: group).environmentObject(dataController)
        }.padding(.bottom, 15)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Image("backgroudImage").edgesIgnoringSafeArea(.all))
        }
        
    var btnBack : some View { Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .aspectRatio(contentMode: .fit)
                        .font(Font.custom("Avenir-Medium", size: 18))
                        .foregroundColor(.white)
                    Text("Back")
                        .font(Font.custom("Avenir-Medium", size: 18))
                        .foregroundColor(.white)
                }
            }
    }
}


/*
struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView()
    }
}
*/
