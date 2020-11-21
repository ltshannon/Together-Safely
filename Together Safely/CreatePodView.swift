//
//  CreatePodView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/4/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct CreatePodView: View {
    @State var name:String = ""
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var podName: String = ""
    @State private var group: Groups = Groups(id: "", adminId: "", name: "", members: [], riskTotals: [:], riskCompiledSring: [], riskCompiledValue: [], averageRisk: "", averageRiskValue: 0)
    
    var body: some View {
        VStack {
            TextField("Pod name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(Font.custom("Avenir-Medium", size: 16))
                .foregroundColor(Color("Colorblack"))
                .padding([.leading, .trailing], 15)
                .padding([.top, .bottom], 10)
            AllContactsCardView(pageType: .createPod, name: self.$name, groupId: "")
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

struct CreatePodView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePodView()
    }
}
