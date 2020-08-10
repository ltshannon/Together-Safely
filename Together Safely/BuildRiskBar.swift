//
//  BuildRiskBar.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/6/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct BuildRiskBar: View {

    var highRiskCount: Int
    var medRiskCount: Int
    var lowRiskCount: Int
    var memberCount: Int
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
        GeometryReader { metrics in
            HStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("Colorred"))
                        .frame(width: (self.calculateWidthPercentage(riskCount: self.highRiskCount, metricWidth: metrics.size.width)))
                    Text("\(self.highRiskCount)")
                        .font(Font.custom("Avenir-Medium", size: 16))
                        .foregroundColor(.white)
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("Colormed"))
                        .frame(width: (self.calculateWidthPercentage(riskCount: self.medRiskCount, metricWidth: metrics.size.width)))
                    Text("\(self.medRiskCount)")
                        .font(Font.custom("Avenir-Medium", size: 16))
                        .foregroundColor(.white)
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("Colorlow"))
                        .frame(width: (self.calculateWidthPercentage(riskCount: self.lowRiskCount, metricWidth: metrics.size.width)))
                    Text("\(self.lowRiskCount)")
                        .font(Font.custom("Avenir-Medium", size: 16))
                        .foregroundColor(.white)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .frame(width: metrics.size.width, height: 25)
        }
    }
    
    private func calculateWidthPercentage(riskCount: Int, metricWidth: CGFloat) -> CGFloat {
        guard riskCount > 0 else {
            return 0.0
        }
        
        return metricWidth * CGFloat((CGFloat(riskCount)/CGFloat(self.memberCount)))
    }
}

/*
struct BuildRiskBar_Previews: PreviewProvider {
    static var previews: some View {
        BuildRiskBar()
    }
}
*/
