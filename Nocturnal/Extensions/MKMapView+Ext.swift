//
//  MKMapView+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/17.
//

import MapKit

extension MKMapView {
    
    func zoomToFit(annotations: [MKAnnotation]) {
        
        var zoomRect = MKMapRect.null
        annotations.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y,
                                      width: 0.01, height: 0.01)
            
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insect = UIEdgeInsets(top: 90, left: 90, bottom: 300, right: 90)
        setVisibleMapRect(zoomRect, edgePadding: insect, animated: true)
    }
    
    func addPointAnnoAndSelect(withCoordinate coordinate: CLLocationCoordinate2D) {
        let pointAnno = MKPointAnnotation()
        pointAnno.coordinate = coordinate
        addAnnotation(pointAnno)
        selectAnnotation(pointAnno, animated: true)
    }
}
