//
//  SpeakerDetailSmallTalkUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 21/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct SpeakerDetailSmallTalkUnit: TypedUnit {
    typealias Cell = SpeakerDetailSmallTalkCollectionViewCell
    
    let identifier: String
    let title: NSAttributedString
    let date: String
    let room: String?
    let talkColor: UIColor
    
    let heightUnit: DimensionUnit
    
    init(identifier: String, title: String, date: String, room: String?, color: UIColor) {
        self.identifier = identifier
        let font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
        let attributed = NSAttributedString(string: title, attributes: [NSFontAttributeName: font])
        self.title = attributed
        self.date = date
        self.room = room
        self.talkColor = color
        heightUnit = DimensionUnit { size in
            let reducedSize = CGSize(width: size.width - 44, height: size.height)
            let frame = attributed.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            return frame.height + 76
        }
    }
    
    func configure(innerView: Cell) {
        innerView.talkTitleLabel.attributedText = title
        innerView.talkTimeLabel.text = date
        innerView.talkRoomLabel.text = room
        innerView.talkTypeIndicatorView.backgroundColor = talkColor
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
