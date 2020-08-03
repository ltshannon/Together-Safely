//
//  FullMemberProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct FullMemberProfileView: View {
    
    var riskScore: Int
    var riskString: String
    var statusText: String
    var emoji: String
    var riskRanges: [Dictionary<String,RiskHighLow>]
    
    var body: some View {
        HStack {
            MemberProfileView(riskScore: riskScore, riskRanges: riskRanges)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 5) {
                Text("Name")
                    .font(Font.custom("Avenir Next Medium", size: 25))
                    .foregroundColor(Color("Color8"))
                Text(statusText)
                    .font(Font.custom("Avenir Next Medium Italic", size: 20))
                    .foregroundColor(Color("Color6"))
                Text(riskString)
                    .font(Font.custom("Avenir Next Medium", size: 20))
                    .foregroundColor(Color("Color7"))
            }
                .padding(.top, 20)
                .padding(.bottom, 20)
            Spacer()
            Text(emoji)
        }
            .padding(.leading, 10)
            .padding(.trailing, 10)
    }
}

/*
struct FullMemberProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FullMemberProfileView()
    }
}
*/

extension String {
    func emojiToImage() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(rect)
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

import UIKit
extension String {
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 1024) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}
