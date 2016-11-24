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
    
    let identifier: String = "DetailHeader"
    
    let imageURL: URL
    let name: String
    let twitter: String
    let heightUnit: DimensionUnit
    
    init(imageURL: URL, name: String, twitter: String) {
        self.imageURL = imageURL
        self.name = name
        self.twitter = twitter
        
        heightUnit = 98
    }
    
    func configure(innerView: Cell) {
        innerView.imageURL = imageURL
        innerView.name = name
        innerView.twitter = twitter
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
