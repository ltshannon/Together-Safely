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
/*
extension  UITextField{
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }

}
*/
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

    func getContactLabel(contactInfo: CNContact, phoneNumber: String) -> String {
        
        for phone in contactInfo.phoneNumbers {
            var number = phone.value.stringValue
            number = number.deletingPrefix("+")
            number = number.deletingPrefix("1")
            number = format(with: "+1XXXXXXXXXX", phone: number)
            
            if number == phoneNumber {
                if let label = phone.label {
                    
                    switch label {
                    case CNLabelHome:
                        return "Home"
                    case CNLabelWork:
                        return "Work"
                    case CNLabelPhoneNumberMobile :
                        return "Mobile"
                    default:
                        return ""
                    }
                }
            }
        }
        return ""
    }
            
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var number = self
        if number.contains("+") {
            number = number.deletingPrefix("+1")
        }
        var pureNumber = number.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
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
    
    func newGetImage(phoneName: String, contacts: FetchedResults<CDContactInfo>) -> Data? {

        for item in contacts {
            if item.phoneNumber == phoneName {
                return item.imageData
            }
        }
        return nil
    }
    
}

extension Color {
    
    func V3GetRiskColor(riskScore: Double, ranges: FetchedResults<CDRiskRanges>) -> Color {
        
        var array: [[String:RiskHighLow]] = []

        for item in ranges {
            let result = try! JSONDecoder().decode([String:RiskHighLow].self, from: item.riskRanges ?? Data())
            array.append(result)
        }

        for riskRange in array {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if riskScore >= min && riskScore <= max {
                    if let value = UInt(range.color, radix: 16) {
                        return Color(hex:Int(value))
                    }
                }
            }
        }

        return Color("Colorgray")
    }
    
    func newGetRiskColor(riskScore: Double, ranges: [[String:RiskHighLow]]) -> Color {
        
        for riskRange in ranges {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if riskScore >= min && riskScore <= max {
                    if let value = UInt(range.color, radix: 16) {
                        return Color(hex:Int(value))
                    }
                }
            }
        }
        return Color("Colorgray")
    }
    
    func getRiskColor(riskScore: Double, dataController: DataController) -> Color {
        
        for riskRange in dataController.riskRanges {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if riskScore >= min && riskScore <= max {
                    if let value = UInt(range.color, radix: 16) {
                        return Color(hex:Int(value))
                    }
                }
            }
        }
        return Color("Colorgray")
    }
    
    func newGetColorFromString(str: String, colors: [[String:String]]) -> Color {
        
        for item in colors {
            if let s = item[str] {
                if let value = UInt(s, radix: 16) {
                    return Color(hex:Int(value))
                }
            }
        }
        return Color("Colorgray")
    }
    
    func V3GetColorFromString(str: String, colors: FetchedResults<CDRiskColors>) -> Color {

        var array: [[String : String]] = []

        for item in colors {
            let result = try! JSONDecoder().decode([String: String].self, from: item.riskColors ?? Data())
            array.append(result)
        }

        for item in array {
            if let s = item[str] {
                if let value = UInt(s, radix: 16) {
                    return Color(hex:Int(value))
                }
            }
        }
 
        return Color("Colorgray")
    }
    
    func getColorFromString(str: String, dataController: DataController) -> Color {
        
        for item in dataController.riskColors {
            if let s = item[str] {
                if let value = UInt(s, radix: 16) {
                    return Color(hex:Int(value))
                }
            }
        }
        return Color("Colorgray")
    }
    
}

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

extension Color {
    public init(hex: Int) {
        self.init(UIColor(hex: hex))
   }
}

extension Image {
    
    func getRiskImage(riskScore: Double, riskRanges: [[String:RiskHighLow]]) -> Image {
    
        for riskRange in riskRanges {
            let element = riskRange.values
            for range in element {
                let min = range.min
                let max = range.max
                if riskScore >= min && riskScore <= max {
                    for key in riskRange.keys {
                        switch key {
                        case "Low Risk":
                            return Image("statusLow")
                        case "Medium Risk":
                            return Image("statusMed")
                        case "High Risk":
                            return Image("statusHigh")
                        default:
                            return Image("statusLow")
                        }
                    }
                }
            }
        }
        return Image("statusLow")
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

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}

extension Array where Element: Hashable {
    func same(as other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.intersection(otherSet))
    }
}


