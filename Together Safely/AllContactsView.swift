//
//  AllContactsView.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/31/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct AllContactsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var name:String = ""
    @State var groupId: String
    var body: some View {
        VStack {
            AllContactsCardView(pageType: .addContacts, name: self.$name, groupId: groupId)
        }
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
struct AllContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AllContactsView()
    }
}
*/
