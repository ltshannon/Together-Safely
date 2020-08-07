//
//  Extensions.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/21/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Contacts

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension  UITextField{
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }

}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension CNContact: Identifiable {
    var name: String {
        return [givenName, middleName, familyName, ].filter{ $0.count > 0}.joined(separator: " ")
    }
}

extension Data {
    
    func getImage(phoneName: String, dict: [[String:ContactInfo]]) -> Data? {
        
        for d in dict {
            if d[phoneName] != nil {
                return(d[phoneName]!.image)
            }
        }
        return nil
    }
    
}

extension Color {
    
    func getRiskColor(riskScore: Int, riskRanges: [[String:RiskHighLow]]) -> Color {
        
        for riskRange in riskRanges {
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

extension Array {
    
    func getWidths(group: Groups, width: CGFloat) -> [CGFloat] {

        var total: Int = 0
        var array: [CGFloat] = [0, 0, 0, 0, 0, 0]
        
        for element in group.riskCompiledSring
        {
            total += Int(group.riskTotals[element]!)
        }
        
        for (_, str) in group.riskCompiledSring.enumerated() {
            
            if total > 0 {
                if let colorValue = group.riskTotals[str] {

                    let v = CGFloat((Int(width) / total) * colorValue)
                    
                    switch str {
                    case "High Risk":
                        array[0] = v
                        array[3] = CGFloat(colorValue)
                    case "Medium Risk":
                        array[1] = v
                        array[4] = CGFloat(colorValue)
                    case "Low Risk":
                        array[2] = v
                        array[5] = CGFloat(colorValue)
                    default:
                        print("error")
                    }
                }
            }
        }
        
        return array
    }
    
}

