//
//  MKPlacemark+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import Foundation
import MapKit

extension MKPlacemark {
    var address: String? {
        guard let subThoroughfare = subThoroughfare else { return nil }
        guard let thoughfare = thoroughfare else { return nil }
        guard let locality = locality else { return nil }
        guard let adminArea = administrativeArea else { return nil}
        
        return "\(subThoroughfare) \(thoughfare), \(locality), \(adminArea) "
    }
}
