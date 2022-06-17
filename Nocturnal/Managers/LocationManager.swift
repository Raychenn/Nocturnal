////
////  LocationManager.swift
////  Nocturnal
////
////  Created by Boray Chen on 2022/6/17.
////
//
//import CoreLocation
//
//class LocationManager: NSObject, CLLocationManagerDelegate {
//    static let shared = LocationManager()
//    var location: CLLocation
//    let manager = CLLocationManager()
//    
//    override init() {
//        
//        self.location = locationManager.location ?? CLLocation()
//        super.init()
//        //        locationManager = CLLocationManager()
//        //        location = locationManager.location
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
//    @available(iOS 14.0, *)
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        //        if manager.authorizationStatus == .authorizedWhenInUse {
//        //            manager.requestAlwaysAuthorization()
//        //        }
//        
//    }
//    
//}
