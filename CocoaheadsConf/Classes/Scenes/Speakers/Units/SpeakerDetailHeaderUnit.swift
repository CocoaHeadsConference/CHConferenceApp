//
//  SpeakerDetailHeaderUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct SpeakerDetailHeaderUnit: TypedUnit {

    typealias Cell = SpeakerDetailHeaderCollectionViewCell
    
    let imageURL: URL
    let name: String
    let headline: String
    
    let identifier: String = "DetailHeader"
    let closeCallback: (()-> Void)?
    
    let heightUnit = DimensionUnit(widthPercent: 0.85)
    
    func configure(innerView: Cell) {
        innerView.closeCallback = closeCallback
        innerView.imageURL = imageURL
        innerView.name = name
        innerView.headline = headline
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
