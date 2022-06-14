//
//  UIFont+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

private enum FontName: String {

    case regular = "NotoSansChakma-Regular"
}

extension UIFont {

    static func medium(size: CGFloat) -> UIFont? {

        var descriptor = UIFontDescriptor(name: FontName.regular.rawValue, size: size)

        descriptor = descriptor.addingAttributes(
            [UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]]
        )

        let font = UIFont(descriptor: descriptor, size: size)

        return font
    }

    static func regular(size: CGFloat) -> UIFont? {

        return STFont(.regular, size: size)
    }

    private static func STFont(_ font: FontName, size: CGFloat) -> UIFont? {

        return UIFont(name: font.rawValue, size: size)
    }
}
