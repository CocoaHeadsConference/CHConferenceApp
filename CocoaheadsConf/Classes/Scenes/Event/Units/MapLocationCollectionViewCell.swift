//
//  MapLocationCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import MapKit

class MapLocationCollectionViewCell: UICollectionViewCell {

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 4
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        containerView.layer.borderWidth = 1
    }

    var centerCoordinate: CoordinateModel? {
        didSet {
            guard let center = centerCoordinate else {
                return
            }
            let span = 0.0100
            let region = MKCoordinateRegionMake(center.coordinate, MKCoordinateSpanMake(span, span))
            mapView.setRegion(region, animated: false)
        }
    }
    
}
