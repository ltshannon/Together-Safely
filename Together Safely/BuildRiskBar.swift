//
//  BuildRiskBar.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/6/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct BuildRiskBar: View {

    var group: Groups
    var array: [CGFloat]
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
    
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    Rectangle()
                        .fill(Color("riskHigh"))
                        .frame(width: array[0] > 0 ? array[0] : 0, height: 50)
                        .cornerRadius(radius: 6, corners: array[1] == 0 && array[2] == 0  ? [.topRight, .bottomRight, .topLeft, .bottomLeft] : [.topLeft, .bottomLeft])
                        Text("\(array[0] > 0 ? String(Int(array[3])) : "")")
                            .font(Font.custom("Avenir-Heavy", size: 20))
                            .foregroundColor(Color("Colorblack"))
                }
                ZStack {
                    Rectangle()
                        .fill(Color("riskMed"))
                        .frame(width: array[1] > 0 ? array[1] : 0, height: 50)
                        .cornerRadius(radius: 6, corners: array[0] == 0 && array[2] == 0 ? [.topRight, .bottomRight, .topLeft, .bottomLeft] : [])
                        Text("\(array[1] > 0 ? String(Int(array[4])) : "")")
                            .font(Font.custom("Avenir-Heavy", size: 20))
                            .foregroundColor(Color("Colorblack"))
                }
                ZStack {
                    Rectangle()
                        .fill(Color("riskLow"))
                        .frame(width: array[2] > 0 ? array[2] : 0, height: 50)
                        .cornerRadius(radius: 6, corners: array[0] == 0 ? [.topRight, .bottomRight, .topLeft, .bottomLeft] : [.topRight, .bottomRight])
                        Text("\(array[2] > 0 ? String(Int(array[5])) : "")")
                            .font(Font.custom("Avenir-Heavy", size: 20))
                            .foregroundColor(Color("Colorblack"))
                }
            }
            .padding(10)
        }
    }
}

/*
struct BuildRiskBar_Previews: PreviewProvider {
    static var previews: some View {
        BuildRiskBar()
    }
}
*/
