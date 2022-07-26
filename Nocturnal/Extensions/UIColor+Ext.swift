//
//  UIColor+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

private enum Color: String {

    case primaryBlue = "#665EE0"

    case deepBlue = "#464099"

    case lightBlue = "#E0DFF9"

    case red = "#f44336"

    case green = "#4caf50"
    
    case deepGray = "#161616"
    
}

extension UIColor {

    static let primaryBlue = color(.primaryBlue)

    static let deepBlue = color(.deepBlue)

    static let lightBlue = color(.lightBlue)

    static let red = color(.red)

    static let green = color(.green)
    
    static let deepGray = color(.deepGray)
    
    private static func color(_ color: Color) -> UIColor {

        return UIColor.hexStringToUIColor(hex: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {

        var colorString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }

        if (colorString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
