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
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
        VStack {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    Text(firebaseService.user.name)
                        .font(Font.custom("Avenir-Heavy", size: 35))
                        .foregroundColor(Color("Colordarkgreen"))
                    Text(firebaseService.user.riskString)
                        .font(Font.custom("Avenir Next Medium", size: 25))
                        .foregroundColor(getColor(riskScore: firebaseService.user.riskScore))
                }
                .frame(width: UIScreen.main.bounds.size.width - 40, height: 200)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding(5)
                ZStack {
                    if firebaseService.user.image != nil {
                        Image(uiImage: UIImage(data:firebaseService.user.image!)!)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .foregroundColor(Color.blue)
                            .padding(5)

                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .foregroundColor(Color.blue)
                            .padding(5)
                    }
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(getColor(riskScore: firebaseService.user.riskScore))
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .offset(x: 30, y: 30)
                }
                    .offset(x: 0, y: -100)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text("Risk factors")
                    .font(Font.custom("Avenir-Heavy", size: 40))
//                    .padding(.leading, 5)
//                    .padding(.trailing, 5)
                    .foregroundColor(Color.white)
                Text("Your risk factors are not visible to your contacts.")
                    .font(Font.custom("Avenir-Heavy", size: 18))
//                    .padding(.leading, 5)
//                    .padding(.trailing, 5)
                    .foregroundColor(Color.white)
            }
                .frame(width: UIScreen.main.bounds.size.width - 40)
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Mobility")
                        .font(Font.custom("Avenir-Heavy", size: 30))
                        .padding(.leading, 20)
                    Spacer()
                    VStack {
                        Text("HIGH")
                            .font(Font.custom("Avenir Next Bold", size: 30))
                            .foregroundColor(Color.white)
                    }
                        .frame(width: 150, height: 60)
                        .background(Color("Colorred"))
                        .cornerRadius(20)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .padding(.trailing, 20)
                }
                Capsule()
                    .fill(Color("Colorblack"))
                    .frame(height: 1)
                    .padding(20)
                HStack {
                    Text("Behaviors")
                        .font(Font.custom("Avenir-Heavy", size: 30))
                        .padding(.leading, 20)
                    Spacer()
                    VStack {
                        Text("MED")
                            .font(Font.custom("Avenir Next Bold", size: 30))
                            .foregroundColor(Color.white)
                    }
                        .frame(width: 150, height: 60)
                        .background(Color("Colormed"))
                        .cornerRadius(20)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .padding(.trailing, 20)
                }
                Capsule()
                    .fill(Color("Colorblack"))
                    .frame(height: 1)
                    .padding(20)
                HStack {
                    Spacer()
                    Image("shareMyRisk")
                        .resizable()
                        .frame(width: 200, height: 50)
                        .padding(.trailing, 20)
                }
            }
            .frame(width: UIScreen.main.bounds.size.width - 40, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding(5)
            Spacer()
            NavigationLink(destination: EditRiskProfile()) {
                HStack {
                    Spacer()
                    Text("Edit risk profile")
                        .font(Font.custom("Avenir-Heavy", size: 25))
                        .foregroundColor(.white)
                    Image(systemName: "pencil.circle")
                        .font(.title)
                        .foregroundColor(.white).opacity(81)
                }
                 .padding(.trailing, 20)
            }
            Spacer()
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
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
                Text("Back")
                    .font(Font.custom("Avenir Next Medium", size: 30))
                    .foregroundColor(.white)
                }
            }
    }
    
    func getColor(riskScore: Int) -> Color {
        
        for riskRange in firebaseService.riskRanges {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if riskScore >= min && riskScore <= max {
                    for key in riskRange.keys {
                        switch key {
                        case "Low Risk":
                            return Color("riskLow")
                        case "Medium Risk":
                            return Color("riskMed")
                        case "High Risk":
                            return Color("riskHigh")
                        default:
                            return Color("Colorgray")
                        }
                    }
                }
            }
        }
        return Color("Colorgray")
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
