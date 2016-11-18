//
//  TalkUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct TalkUnit: TypedUnit {

    typealias Cell = TalkCollectionViewCell
    
    let talk: TalkModel
    let titleAttributedText: NSAttributedString
    let summaryAttributedText: NSAttributedString
    
    var identifier: String {
        return "talk-\(talk.id)"
    }
    
    let heightUnit: DimensionUnit
    
    init(talk: TalkModel) {
        self.talk = talk
        let title = NSAttributedString(string: talk.title, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)])
        let summary = NSAttributedString(string: self.talk.summary, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
        self.titleAttributedText = title
        self.summaryAttributedText = summary
        self.heightUnit = DimensionUnit { size in
            let reductedSize = CGSize(width: size.width - 90, height: size.height)
            let titleFrame = title.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            
            let summaryFrame = summary.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            return round(titleFrame.height + summaryFrame.height) + 86
        }
        
    }
    
    func configure(innerView: Cell) {
        innerView.backgroundColor = .clear
        innerView.speakerImageURL = talk.speaker?.imageURL
        innerView.placeLabel.text = talk.room?.title ?? "Não definido"
        innerView.speakerNameLabel.text = talk.speaker?.name ?? "Não definido"
        innerView.talkTitleLabel.text = talk.title
        innerView.talkSummaryLabel.text = talk.summary
        innerView.timeLabel.text = TalkDashboardUnits.timeDateFormatter.string(from: talk.date)
        innerView.talkColor = talk.type.color
        innerView.speakerImageView.isHidden = !talk.type.hasImage
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
