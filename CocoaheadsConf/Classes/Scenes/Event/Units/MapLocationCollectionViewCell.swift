//
//  MapLocationCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import MapKit

class MapLocationCollectionViewCell: UICollectionViewCell, MKMapViewDelegate {

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 4
        mapView.layer.cornerRadius = 4
    }

    var centerCoordinate: CoordinateModel? {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            guard let center = centerCoordinate else {
                return
            }
            //let span = 0.0050
            let region = MKCoordinateRegion(center: center.coordinate, span: MKCoordinateSpan(latitudeDelta: center.latitude, longitudeDelta: center.longitude))
            mapView.setRegion(region, animated: false)
            let annotation = EventLocationPin(coordinate: center.coordinate)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is EventLocationPin {
            let identifier = "event"
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = #imageLiteral(resourceName: "map-pin")
            return annotationView
        }
        return nil
    }
    
}
