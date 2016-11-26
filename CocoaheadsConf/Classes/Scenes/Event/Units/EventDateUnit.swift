//
//  EventDateUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct EventDateUnit: TypedUnit {

    typealias Cell = EventDateCollectionViewCell
    
    let identifier = "EventDate"
    let heightUnit: DimensionUnit = 120
    
    let event: EventModel
    
    func configure(innerView: Cell) {
        innerView.startDate = event.startDate
        innerView.endDate = event.endDate
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
