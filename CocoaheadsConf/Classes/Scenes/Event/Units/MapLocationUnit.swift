//
//  MapLocationUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose
import MapKit

struct MapLocationUnit: TypedUnit, SelectableUnit {
    
    typealias Cell = MapLocationCollectionViewCell
    
    let identifier = "MapLocation"
    let heightUnit: DimensionUnit = DimensionUnit(widthPercent: 0.65)
    
    let location: LocationModel
    
    func configure(innerView: Cell) {
        innerView.addressLabel.text = location.address
        innerView.centerCoordinate = location.coordinate
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
    func didSelect() {
        let regionDistance:CLLocationDistance = 1000
        let coordinates = location.coordinate.coordinate
        let regionSpan = MKCoordinateRegion(center: coordinates,
                                            latitudinalMeters: regionDistance,
                                            longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.address
        mapItem.openInMaps(launchOptions: options)
    }
    
}

