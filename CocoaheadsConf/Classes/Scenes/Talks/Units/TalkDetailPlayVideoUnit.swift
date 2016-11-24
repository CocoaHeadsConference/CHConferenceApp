//
//  TalkDetailPlayVideoUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct TalkDetailPlayVideoUnit : TypedUnit {

    typealias Cell = TalkDetailPlayVideoCollectionViewCell
    
    let identifier = "PlayVideoCell"
    let heightUnit: DimensionUnit = 38
    
    var videoButtonCallback: (() -> Void)?
    var buttonTitle: String
    
    func configure(innerView: Cell) {
        innerView.videoButtonCallback = videoButtonCallback
        innerView.playButton.setTitle(buttonTitle, for: .normal)
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
