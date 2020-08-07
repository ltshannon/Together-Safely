//
//  FullMemberProfileView.swift
//  Together Safely
//
//  Created by Larry Shannon on 8/1/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct FullMemberProfileView: View {

    var groupId: String
    var member: Member
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var getRiskColor: Color = Color.white
    @State private var getImageForPhone: Data = Data()
    
    var body: some View {
        HStack {
            MemberProfileView(
                image: getImageForPhone.getImage(phoneName: self.member.phoneNumber, dict: self.firebaseService.contactInfo),
                groupId: groupId,
                riskScore: member.riskScore,
                riskRanges: firebaseService.riskRanges).environmentObject(self.firebaseService)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 5) {
                Text(self.getName(phoneName: self.member.phoneNumber, dict: self.firebaseService.contactInfo))
                Text(member.status.text)
                    .font(Font.custom("Avenir Next Medium Italic", size: 20))
                    .foregroundColor(Color("Colorgray"))
                Text(member.riskString)
                    .font(Font.custom("Avenir Next Medium", size: 20))
                    .foregroundColor(getRiskColor.getRiskColor(riskScore: member.riskScore, riskRanges: self.firebaseService.riskRanges))
            }
                .padding(.top, 20)
                .padding(.bottom, 20)
            Spacer()
            Text(member.status.emoji)
            .font(Font.custom("Avenir Next Medium", size: 50))
        }
            .padding(.leading, 10)
            .padding(.trailing, 10)
    }
    
    func getName(phoneName: String, dict: [[String:ContactInfo]]) -> String {
        
        for d in dict {
            if d[phoneName] != nil {
                return(d[phoneName]!.name)
            }
        }
        return phoneName
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
