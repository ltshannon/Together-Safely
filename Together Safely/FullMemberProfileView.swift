//
//  FullMemberProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct FullMemberProfileView: View {

    var member: Member
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    
    @FetchRequest(
        entity: CDContactInfo.entity(),
        sortDescriptors: []
    ) var contactInfo: FetchedResults<CDContactInfo>
    
    @FetchRequest(
        entity: CDRiskRanges.entity(),
        sortDescriptors: []
    ) var riskRanges: FetchedResults<CDRiskRanges>

    var body: some View {

        HStack {
            MemberProfileByIndexView(contacts: contactInfo, phoneNumber: member.phoneNumber, riskScore: member.riskScore)

            VStack(alignment: .leading, spacing: 5) {
                Text(self.getName(phoneName: member.phoneNumber, contacts: contactInfo))
                Text(member.status.text)
                    .font(Font.custom("Avenir-Medium", size: 14))
                    .foregroundColor(Color("Colorgray"))
                Text(member.riskString)
                    .font(Font.custom("Avenir-Medium", size: 14))
                    .foregroundColor(getRiskColor.V3GetRiskColor(riskScore: member.riskScore, ranges: riskRanges))
            }
            Spacer()
            Text(member.status.emoji)
            .font(Font.custom("Avenir Next Medium", size: 45))
        }
    }
    
    func getName(phoneName: String, contacts: FetchedResults<CDContactInfo>) -> String {
        
        for item in contacts {
            if item.phoneNumber == phoneName {
                return item.name ?? phoneName
            }
        }
        return phoneName
    }
    
}

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
