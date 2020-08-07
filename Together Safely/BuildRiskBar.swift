//
//  BuildRiskBar.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/6/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct BuildRiskBar: View {

    var array: [CGFloat]
//    var redValue: CGFloat
//    var yellowValue: CGFloat
//    var greenValue: CGFloat
    
    var body: some View {
    
        VStack(spacing: 0) {
            HStack {
                Rectangle()
                    .fill(Color("riskHigh"))
                    .frame(width: array.count == 1 ? array[0] : 0, height: 50)
                    .padding(.trailing, -4)
                    .cornerRadius(radius: 6, corners: array.count == 1 ? [.topRight, .bottomRight, .topLeft, .bottomLeft] : [.topRight, .bottomRight])
                Rectangle()
                    .fill(Color("riskMed"))
                    .frame(width: array.count == 2 ? array[1] : 0, height: 50)
                    .padding(.leading, -4)
                    .padding(.trailing, -4)
                    .cornerRadius(radius: 6, corners: array.count == 1 ? [.topRight, .bottomRight, .topLeft, .bottomLeft] : [.topRight, .bottomRight])
                Rectangle()
                    .fill(Color("riskLow"))
                    .frame(width: array.count == 3 ? array[2] : 0, height: 50)
                    .padding(.leading, -3)
                    .cornerRadius(radius: 6, corners: array.count == 1 ? [.topRight, .bottomRight, .topLeft, .bottomLeft] : [.topRight, .bottomRight])
            }
            .padding(0)
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
