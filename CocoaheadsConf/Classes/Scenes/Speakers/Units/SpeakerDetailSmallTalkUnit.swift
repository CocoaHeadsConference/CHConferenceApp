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
    let summary: NSAttributedString
    let date: String
    let room: String?
    let talkColor: UIColor
    
    let heightUnit: DimensionUnit
    
    init(identifier: String, title: String, summary: String, date: String, room: String?, color: UIColor) {
        self.identifier = identifier
        let titleFont = UIFont.systemFont(ofSize: 22, weight: .medium)
        let titleAttributed = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: titleFont])
        let summaryFont = UIFont.systemFont(ofSize: 15)
        let summaryAttributed = NSAttributedString(string: summary, attributes: [NSAttributedString.Key.font: summaryFont])
        self.title = titleAttributed
        self.summary = summaryAttributed
        self.date = date
        self.room = room
        self.talkColor = color
        heightUnit = DimensionUnit { size in
            let reducedSize = CGSize(width: size.width - 66, height: size.height)
            let titleFrame = titleAttributed.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            let summaryFrame = summaryAttributed.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            return titleFrame.height + summaryFrame.height + 66
        }
    }
    
    func configure(innerView: Cell) {
        innerView.talkTitleLabel.attributedText = title
        innerView.talkSummaryLabel.attributedText = summary
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
