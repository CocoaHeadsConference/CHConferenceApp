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
class SpeakerDetailView: NibDesignable {

    @IBOutlet var detailView: CollectionStackView! {
        didSet {
            detailView.container.lineSpace = 4
            detailView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
    }
    
    var closeCallback: (()-> Void)?
    
    var state: SpeakerDetailViewState = SpeakerDetailViewState() {
        didSet {
            detailView.container.state = ComposeSpeakerDetailView(with: state, closeCallback: closeCallback)
        }
    }    
    
}


func ComposeSpeakerDetailView(with state: SpeakerDetailViewState, closeCallback: (()-> Void)?)-> [ComposingUnit] {
    
    guard let speaker = state.speaker else { return [] }

    let header = SpeakerDetailHeaderUnit(imageURL: speaker.imageURL, name: speaker.name, headline: speaker.headline, citation: speaker.bio, closeCallback: closeCallback)
    let social = SpeakerDetailAllSocialUnit(twitter: speaker.twitterHandle, linkedIn: speaker.linkedInHandle, github: speaker.githubHandle)
    
    var units: [ComposingUnit] = [header]
    
    units.add(manyIfLet: state.talks) { talks in
        let timeDateFormatter = DateFormatter()
        timeDateFormatter.dateFormat = "EEEE, HH:mm •"
        
        return talks.map { SpeakerDetailSmallTalkUnit(identifier: String($0.id), title: $0.title, date: timeDateFormatter.string(from: $0.date).capitalized, room: $0.room?.title, color: $0.type.color) }
    }
    
    units.append(social)
    
    return units
}
