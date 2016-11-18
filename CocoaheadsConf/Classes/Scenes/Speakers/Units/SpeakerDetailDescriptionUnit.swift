//
//  SpeakerDetailDescriptionUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct SpeakerDetailDescriptionUnit: TypedUnit {
    
    typealias Cell = SpeakerDetailDescriptionCollectionViewCell
    
    let identifier: String = "DescriptionUnit"
    
    let bio: NSAttributedString
    let heightUnit: DimensionUnit
    
    init(bio: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)) {
        let text = NSAttributedString(string: bio, attributes: [NSFontAttributeName: font])
        self.bio = text
        heightUnit = DimensionUnit { size in
            let reductedSize = CGSize(width: size.width - 32, height: size.height)
            let frame = text.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            return round(frame.height) + 16
        }
    }
    
    
    
    func configure(innerView: Cell) {
        innerView.bio = bio
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
