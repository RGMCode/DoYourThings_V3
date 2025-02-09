//
//  UIColor+Hex.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import UIKit
import SwiftUI

extension UIColor {
    convenience init?(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        guard hexFormatted.count == 8 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        let a = CGFloat(rgbValue & 0x000000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func toHex(alpha: Bool = true) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count > 3 ? components[3] : 1.0)
        
        if alpha {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255),
                          lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255))
        }
    }
}

extension Color {
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else {
            return nil
        }
        self.init(uiColor)
    }
}

