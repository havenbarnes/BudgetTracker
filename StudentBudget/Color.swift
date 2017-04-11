//
//  Color.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/10/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

enum Color: String {
    case red = "E74C3C"
    case orange = "F26522"
    case yellow = "F1C40F"
    case green = "27AE60"
    case blue = "2980B9"
    case purple = "8E44AD"
    case pink = "F62459"
    case gray = "BFBFBF"
    
    static let allValues = [red, orange, yellow, green, blue, purple, pink, gray]
    func color(_ color: Color) -> UIColor {
        return UIColor(hex: color.rawValue)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hexString).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hexString.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
