//
//  ReminderUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose
import EventKitUI

struct ReminderUnit: TypedUnit {

    typealias Cell = ReminderCollectionViewCell
    
    let identifier = "reminder"
    let heightUnit: DimensionUnit = 72
    
    let event: EventModel
    
    func configure(innerView: Cell) {
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
