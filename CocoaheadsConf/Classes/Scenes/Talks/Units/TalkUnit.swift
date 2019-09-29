//
//  TalkUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct TalkUnit: TypedUnit, SelectableUnit {

    typealias Cell = TalkCollectionViewCell
    
    let talk: TalkModel
    let callback: ((TalkModel)-> Void)?
    let titleAttributedText: NSAttributedString
    let summaryAttributedText: NSAttributedString
    
    var identifier: String {
        return "talk-\(talk.id)"
    }
    
    let heightUnit: DimensionUnit
    
    init(talk: TalkModel, callback:((TalkModel)-> Void)?) {
        self.talk = talk
        self.callback = callback
        let title = NSAttributedString(string: talk.title, attributes: [.font : UIFont.systemFont(ofSize: 20, weight: .bold)])
        let summary = NSAttributedString(string: self.talk.summary, attributes: [.font: UIFont.systemFont(ofSize: 15)])
        self.titleAttributedText = title
        self.summaryAttributedText = summary
        self.heightUnit = DimensionUnit { size in
            let reductedSize = CGSize(width: size.width - 108, height: size.height)
            let titleFrame = title.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            
            let summaryFrame = summary.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            return round(titleFrame.height + summaryFrame.height) + 90
        }
        
    }
    
    func configure(innerView: Cell) {
        innerView.backgroundColor = talk.type.backgroundColor
        innerView.speakerImageURL = talk.speaker?.imageURL
        innerView.placeLabel.text = talk.room?.title ?? ""
        innerView.speakerNameLabel.text = talk.speaker?.name ?? ""
        innerView.talkTitleLabel.text = talk.title
        innerView.talkSummaryLabel.text = talk.summary
        innerView.timeLabel.text = TalkDashboardUnits.timeDateFormatter.string(from: talk.date)
        innerView.talkColor = talk.type.color
        innerView.speakerImageView.isHidden = !talk.type.hasImage
        innerView.videoImageView.isHidden = talk.video == nil
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
    func didSelect() {
        callback?(talk)
    }
    
}
