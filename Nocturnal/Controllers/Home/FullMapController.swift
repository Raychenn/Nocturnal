//
//  FullMapController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import MapKit

class FullMapController: UIViewController {
    
    private let mapView: MKMapView = {
       let map = MKMapView()
        
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.fillSuperview()
    }
}
