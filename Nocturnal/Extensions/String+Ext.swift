//
//  String+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/24.
//

import UIKit

    func flag(country: String) -> String {
        let base: UInt32 = 127397
        var string = ""
        for unicode in country.unicodeScalars {
            string.unicodeScalars.append(UnicodeScalar(base + unicode.value) ?? UnicodeScalar(0))
        }
        return String(string)
    }
