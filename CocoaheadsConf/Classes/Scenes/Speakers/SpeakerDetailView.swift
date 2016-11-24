//
//  SpeakerDetailView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose
import NibDesignable

@IBDesignable
class SpeakerDetailView: CollectionStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hexString: "004D40")
        container.lineSpace = 0
        container.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var state: SpeakerDetailViewState = SpeakerDetailViewState() {
        didSet {
            container.state = ComposeSpeakerDetailView(with: state)
        }
    }    
    
}


func ComposeSpeakerDetailView(with state: SpeakerDetailViewState)-> [ComposingUnit] {
    
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
    
    let validTwitterHandle = speaker.twitterHandle.characters.count > 0
    let validLinkedInHandle = speaker.linkedInHandle.characters.count > 0
    let validGithubHandle = speaker.githubHandle.characters.count > 0
    units.add(manyIf: validTwitterHandle || validLinkedInHandle || validGithubHandle) {
        let spacer = ViewUnit<UIView>(id:"bottomSpacer", traits: [.height(4)])
        return [spacer, SpeakerDetailAllSocialUnit(twitter: speaker.twitterHandle, linkedIn: speaker.linkedInHandle, github: speaker.githubHandle)]
    }
    
    return units
}
