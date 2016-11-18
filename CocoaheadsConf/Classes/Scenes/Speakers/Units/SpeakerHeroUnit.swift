//
//  SpeakerHeroUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct SpeakerHeroUnit: TypedUnit, SelectableUnit {

    typealias Cell = SpeakerHeroCollectionViewCell
    
    var identifier: String {
        return String(describing: speaker.id)
    }
    let heightUnit = DimensionUnit(widthPercent: 1.25)
    
    let speaker: SpeakerModel
    
    var selectCallback: ((SpeakerModel)-> Void)?
    
    init(speaker: SpeakerModel, callback: ((SpeakerModel)-> Void)?) {
        self.speaker = speaker
        self.selectCallback = callback
    }
    
    func configure(innerView: Cell) {
        innerView.speakerImageURL = speaker.imageURL
        innerView.speakerName = speaker.name
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
    
    func didSelect() {
        selectCallback?(speaker)
    }
}
