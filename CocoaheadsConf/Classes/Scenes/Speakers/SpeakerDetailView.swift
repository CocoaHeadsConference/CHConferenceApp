//
//  SpeakerDetailView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

@IBDesignable
class SpeakerDetailView: CollectionStackView {

    var didTapSafariCallback: ((URL)-> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Theme.shared.mainColor
        container.lineSpace = 0
        container.backgroundColor = Theme.shared.shadowColor.withAlphaComponent(0.8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var state: SpeakerDetailViewState = SpeakerDetailViewState() {
        didSet {
            container.state = ComposeSpeakerDetailView(with: state, urlCallback: didTapSafariCallback)
        }
    }    
    
}


func ComposeSpeakerDetailView(with state: SpeakerDetailViewState, urlCallback:((URL)-> Void)?)-> [ComposingUnit] {
    
    guard let speaker = state.speaker else { return [] }
    
    let header = SpeakerDetailHeaderUnit(imageURL: speaker.imageURL, name: speaker.name, twitter: speaker.twitterHandle)
    
    let desc = SpeakerDetailDescriptionUnit(headline: speaker.headline, bio: speaker.bio)
    
    let topSpacer = ViewUnit<UIView>(id:"topSpacer", traits: [.height(4)])
    
    var units: [ComposingUnit] = [header, desc, topSpacer]
    
    units.add(manyIfLet: state.talks) { talks in
        let timeDateFormatter = DateFormatter()
        timeDateFormatter.dateFormat = "EEEE, HH:mm •"
        
        return talks.map { SpeakerDetailSmallTalkUnit(identifier: String($0.id), title: $0.title, summary: $0.summary, date: timeDateFormatter.string(from: $0.date).capitalized, room: $0.room?.title, color: $0.type.color) }
    }
    
    units.add(manyIfLet: speaker.twitterHandle) { twitter in
        let topSpacer = ViewUnit<UIView>(id:"twitter-top", traits: [.height(8)])
        let bottomSpacer = ViewUnit<UIView>(id:"twitter-bottom", traits: [.height(8)])
        let unit = EventFollowOnTwitterUnit(color: Theme.shared.actionColor, twitter: twitter) {
            guard let url = URL(string:"https://twitter.com/\(twitter)") else {
                return
            }
            urlCallback?(url)
        }
        return [topSpacer, unit, bottomSpacer]
    }
    
    return units
}
