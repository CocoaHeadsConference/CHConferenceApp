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
    var units: [ComposingUnit] = []
    units.add(manyIfLet: state.speaker) { speaker in
        let header = SpeakerDetailHeaderUnit(imageURL: speaker.imageURL, name: speaker.name, headline: speaker.headline, closeCallback: closeCallback)
        let social = SpeakerDetailAllSocialUnit(twitter: speaker.twitterHandle, linkedIn: speaker.linkedInHandle, github: speaker.githubHandle)
        let bio = SpeakerDetailDescriptionUnit(bio: speaker.bio)
        return [header, social, bio]
    }
    return units
}
