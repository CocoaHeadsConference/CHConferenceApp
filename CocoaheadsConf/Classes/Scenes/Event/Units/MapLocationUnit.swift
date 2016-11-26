//
//  MapLocationUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct MapLocationUnit: TypedUnit {
    
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
    
}

