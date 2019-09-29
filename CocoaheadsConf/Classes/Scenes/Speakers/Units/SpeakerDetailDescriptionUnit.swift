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
    let headline: NSAttributedString
    let heightUnit: DimensionUnit
    
    init(headline: String, bio: String) {
        let bioFont = UIFont.systemFont(ofSize: 15)
        let headlineFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        let bioText = NSAttributedString(string: bio, attributes: [.font: bioFont])
        let headlineText = NSAttributedString(string: headline, attributes: [.font: headlineFont])
        self.bio = bioText
        self.headline = headlineText
        heightUnit = DimensionUnit { size in
            let reductedSize = CGSize(width: size.width - 32, height: size.height)
            let frame = bioText.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            let headlineFrame = headlineText.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            return round(frame.height + headlineFrame.height) + 30
        }
    }
    
    
    
    func configure(innerView: Cell) {
        innerView.bio = bio
        innerView.headline = headline
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
