//
//  UserProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/3/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var getRiskColor: Color = Color.white
    @State private var image: Image = Image("")
    
    @FetchRequest(
        entity: CDUser.entity(),
        sortDescriptors: []
    ) var user: FetchedResults<CDUser>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var items: FetchedResults<CDRiskRanges>
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text(user.first?.userName ?? "")
                        .font(Font.custom("Avenir-Medium", size: 18))
                        .foregroundColor(Color("Colordarkgreen"))
                    Text(user.first?.riskString ?? "")
                        .font(Font.custom("Avenir-Medium", size: 16))
                        .foregroundColor(getRiskColor.V3GetRiskColor(riskScore: user.first?.riskScore ?? 0, ranges: items))
                        .padding(.bottom, 15)
                }
                .frame(minWidth: 300, maxWidth: .infinity)
                .frame(height: 150)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                ZStack {
                    if user.first?.image != nil {
                        Image(uiImage: UIImage(data: (user.first?.image!)!)!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .padding(5)

                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding([.top, .bottom], 5)
                    }
                    Circle()
                        .frame(width: 25, height: 25)
                        .foregroundColor(getRiskColor.V3GetRiskColor(riskScore: user.first?.riskScore ?? 0, ranges: items))
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .offset(x: 25, y: 25)
                }.offset(x: 0, y: -50)
            }
// Commented out Risk Factors 10/18/2020 LTS
            Spacer()
/*
            VStack(alignment: .leading, spacing: 0) {
                Text("Risk factors")
                    .font(Font.custom("Avenir-Heavy", size: 22))
                    .foregroundColor(Color.white)
                Text("Your risk factors are not visible to your contacts.")
                    .font(Font.custom("Avenir-Medium", size: 16))
                    .foregroundColor(Color.white)
            }
            .padding(10)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Mobility")
                        .font(Font.custom("Avenir-Medium", size: 18))
                    Spacer()
                    image.getRiskImage(riskScore: dataController.user.riskScore, riskRanges: self.dataController.riskRanges)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 25)
                }.padding(15)
                Capsule()
                    .fill(Color("Colorblack"))
                    .frame(height: 1)
                    .padding([.leading, .trailing], 15)
                HStack {
                    Text("Behaviors")
                        .font(Font.custom("Avenir-Medium", size: 18))
                    Spacer()
                    image.getRiskImage(riskScore: dataContoller.user.riskScore, riskRanges: self.dataController.riskRanges)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 25)
                }.padding(15)
            }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
            Spacer()
//            NavigationLink(destination: EditRiskProfile().environmentObject(dataController)) {
            NavigationLink(destination: EditRiskProfile2().environmentObject(dataController)) {
                HStack {
                    Spacer()
                    Text("Edit risk profile")
                        .font(Font.custom("Avenir-Heavy", size: 22))
                        .foregroundColor(.white)
                    Image(systemName: "pencil.circle")
                        .font(.title)
                        .foregroundColor(.white).opacity(81)
                }
            }
*/
        }
            .padding(15)
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

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
