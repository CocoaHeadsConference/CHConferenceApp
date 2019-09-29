//
//  EventFollowOnTwitterUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct EventFollowOnTwitterUnit: TypedUnit, SelectableUnit {

    typealias Cell = EventFollowOnTwitterCollectionViewCell
    
    let identifier = "FollowOnTwitter"
    let heightUnit: DimensionUnit = 48
    
    let color: UIColor
    let twitter: String
    var callback: (()-> Void)?
    
    func configure(innerView: Cell) {
        innerView.mainColor = color
        innerView.twitterHandle = twitter
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
    func didSelect() {
        self.callback?()
    }
    
}
