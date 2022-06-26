//
//  FullMapController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import MapKit
import CoreLocation

class FullMapController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        return map
    }()
    
//    private lazy var backButton: UIButton = {
//       let button = UIButton()
//        button.setImage( UIImage(systemName: "chevron.left"), for: .normal)
//        button.tintColor = .black
//        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
//        return button
//    }()
    
    let destinationCoordinate: CLLocationCoordinate2D
    
    let locationManager = CLLocationManager()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkLocationServices()
    }
    
    init(coodinate: CLLocationCoordinate2D) {
        self.destinationCoordinate = coodinate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMap()
        getDirections()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
//    @objc func didTapBackButton() {
//        navigationController?.popViewController(animated: true)
//    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.fillSuperview()
//        view.addSubview(backButton)
//        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    private func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: destinationCoordinate.latitude,
                                                       longitude: destinationCoordinate.longitude)
        let region = MKCoordinateRegion(center: destinationCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
//        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotation(annotation)
        mapView.zoomToFit(annotations: [annotation])
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // alet user and jump into settings page to turn on location access
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections() {
        guard let currentCoordinate = locationManager.location?.coordinate else {
            print("do not have user current location")
            return
        }
        
        let request = createDirctionRequest(from: currentCoordinate)
        let directions = MKDirections(request: request)
        resetMapView()
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let response = response, error == nil else {
                print("Fail to calculate directions \(String(describing: error))")
                return
            }
            
            response.routes.forEach { route in
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirctionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
//        let destinationCoordinate = destinationCoordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    func resetMapView() {
        mapView.removeOverlays(mapView.overlays)
    }
}
// MARK: - CLLocationManagerDelegate

extension FullMapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

}

// MARK: - MKMapViewDelegate

extension FullMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlay = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .primaryBlue
        
        return renderer
    }
}
