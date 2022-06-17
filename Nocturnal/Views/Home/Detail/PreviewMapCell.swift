//
//  PreviewMapCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import MapKit

protocol PreviewMapCellDelegate: AnyObject {
    func handleShowFullMap(cell: PreviewMapCell)
}

class PreviewMapCell: UITableViewCell {

    // MARK: - Properties
    
    var event: Event? {
        didSet {
            guard let event = event else { return }
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: event.destinationLocation.latitude, longitude: event.destinationLocation.longitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    weak var delegate: PreviewMapCellDelegate?
    
    private lazy var mapView: MKMapView = {
       let view = MKMapView()
        view.isScrollEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSmallMap))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mapView)
        mapView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureCell(with event: Event) {
        
    }
    
    // MARK: - Selectors
    
    @objc func didTapSmallMap() {
        delegate?.handleShowFullMap(cell: self)
    }
}
