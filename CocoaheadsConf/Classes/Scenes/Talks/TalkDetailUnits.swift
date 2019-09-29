//
//  TalkDetailUnits.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 21/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose
import Kingfisher

struct TalkDetailUnits {

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, HH:mm"
        return formatter
    }()
    
    static func Header(for talk: TalkModel)-> ComposingUnit {
        let height = DimensionUnit { size in
            let reducedSize = CGSize(width: size.width - 112, height: size.height)
            let font = UIFont.systemFont(ofSize: 18, weight: .bold)
            let attributed = NSAttributedString(string: talk.title, attributes: [.font: font])
            let frame = attributed.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            return frame.height + 80
        }
        let header = ViewUnit<DetailHeaderCollectionViewCell>(id: "header", traits: [.height(height)]) { view in
            view.talkNameLabel.text = talk.title
            view.talkTimeLabel.text = formatter.string(from: talk.date)
            view.talkLocationLabel.text = talk.room?.title
            view.talkIndicatorView.backgroundColor = talk.type.color
            view.talkSpeakerImageView.kf.setImage(with: talk.speaker?.imageURL, placeholder: ConferenceStyleKit.imageOfCocoaHeadsLogo, options: nil, progressBlock: nil) { _ in }
            view.talkSpeakerImageView.isHidden = !talk.type.hasImage
        }
        return header
    }
    
    static func Description(for talk: TalkModel)-> ComposingUnit {
        let summaryFont = UIFont.systemFont(ofSize: 22, weight: .medium)
        let descriptionFont = UIFont.systemFont(ofSize: 15)
        let attributedSummary = NSAttributedString(string: talk.summary, attributes: [.font: summaryFont])
        let attributedDescription = NSAttributedString(string: talk.fullDescription, attributes: [.font: descriptionFont])
        let height = DimensionUnit { size in
            let reducedSize = CGSize(width: size.width - 32, height: size.height)
            let summaryFrame = attributedSummary.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            let descriptionFrame = attributedDescription.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            return summaryFrame.height + descriptionFrame.height + 35
        }
        let unit = ViewUnit<TalkDetailDescriptionCollectionViewCell>(id: "description", traits: [.height(height)]) { view in
            view.summaryLabel.attributedText = attributedSummary
            view.descriptionLabel.attributedText = attributedDescription
        }
        return unit
    }
    
    static func Play(playHandler: (() -> Void)?)-> ComposingUnit {
        let unit = TalkDetailPlayVideoUnit(videoButtonCallback: playHandler)
        return unit
    }
    
    static func Spacer(with id: String)-> ComposingUnit {
        return ViewUnit<UIView>(id: id, traits: [.height(4)])
    }
    
    static func Stats(for talk: TalkModel)-> ComposingUnit {
        let durationUnit = StatUnit(id: "duration", title: "Duração", value: "\(talk.duration) min")
        let capacityUnit = StatUnit(id: "capacity", title: "Capacidade", value: "\(talk.room?.capacity ?? 0)")
        let container = CollectionStackUnit(identifier: "stats", direction: .verticalGrid(columns: 2), traits: [], units: [durationUnit, capacityUnit]) { collectionView in
            collectionView.itemSpace = 4
            collectionView.lineSpace = 4
        }
        return container
        
    }
    
    static func StatUnit(id: String, title: String, value: String)-> ComposingUnit {
        let unit = ViewUnit<TalkDetailStatsCollectionViewCell>(id: id, traits: [.height(DimensionUnit(widthPercent: 0.5))]) { view in
            view.nameLabel.text = title
            view.valueLabel.text = value
            view.backgroundColor = Theme.shared.shadowColor.withAlphaComponent(0.25)
        }
        return unit
    }
    
}
