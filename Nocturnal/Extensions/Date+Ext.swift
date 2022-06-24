//
//  Date+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
extension Date {
    
    static var dateTimeFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
                
        return formatter
        
    }
    
    static var dateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM/dd/yyyy"
                
        return formatter
        
    }
}

// MARK: - Zodiac Signs

public enum Zodiac {
    case aries
    case taurus
    case gemini
    case cancer
    case lion
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capicorn
    case aquarius
    case pisces
    case undefined
}

func getZodiacSign(_ date: Date) -> String {

    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)

    switch (day, month) {
    case (21...31, 1), (1...19, 2):
        return "aquarius"
    case (20...29, 2), (1...20, 3):
        return "pisces"
    case (21...31, 3), (1...20, 4):
        return "aries"
    case (21...30, 4), (1...21, 5):
        return "taurus"
    case (22...31, 5), (1...21, 6):
        return "gemini"
    case (22...30, 6), (1...22, 7):
        return "cancer"
    case (23...31, 7), (1...22, 8):
        return "leo"
    case (23...31, 8), (1...23, 9):
        return "virgo"
    case (24...30, 9), (1...23, 10):
        return "libra"
    case (24...31, 10), (1...22, 11):
        return "scorpio"
    case (23...30, 11), (1...21, 12):
        return "sagittarius"
    default:
        return "capricorn"
    }

}

//public var zodiac: Zodiac {
//    guard let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
//        else { return .undefined }
//
//    let dateComponents = gregorianCalendar.components([.month, .day], from: self)
//
//    let month = dateComponents.month
//    let day = dateComponents.day
//
//    switch (month!, day!) {
//    case (3, 21...31), (4, 1...19):
//        return .aries
//    case (4, 20...30), (5, 1...20):
//        return .taurus
//    case (5, 21...31), (6, 1...20):
//        return .gemini
//    case (6, 21...30), (7, 1...22):
//        return .cancer
//    case (7, 23...31), (8, 1...22):
//        return .lion
//    case (8, 23...31), (9, 1...22):
//        return .virgo
//    case (9, 23...30), (10, 1...22):
//        return .libra
//    case (10, 23...31), (11, 1...21):
//        return .scorpio
//    case (11, 22...30), (12, 1...21):
//        return .sagittarius
//    case (12, 22...31), (1, 1...19):
//        return .capicorn
//    case (1, 20...31), (2, 1...18):
//        return .aquarius
//    case (2, 19...29), (3, 1...20):
//        return .pisces
//    default:
//        return .undefined
//    }
//}
