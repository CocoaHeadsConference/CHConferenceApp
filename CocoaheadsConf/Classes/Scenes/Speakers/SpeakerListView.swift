//
//  SpeakerListView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 11/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import NibDesignable
import Compose

@IBDesignable
class SpeakerListView: CollectionStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        container.direction = .verticalGrid(columns: 3)
        container.sectionInset = UIEdgeInsets(top: -20, left: 2, bottom: 2, right: 0)
        container.itemSpace = 2
        container.lineSpace = 2
        self.backgroundColor = UIColor(hexString: "004D40")
        container.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var displayCallback: ((SpeakerModel)-> Void)?
    
    var state: SpeakersListState = SpeakersListState(speakers: []) {
        didSet {
            container.state = ComposeSpeakerListView(with: state, selectCallback: displayCallback)
        }
    }
    
}

func ComposeSpeakerListView(with state: SpeakersListState, selectCallback: ((SpeakerModel)-> Void)?)-> [ComposingUnit] {
    return state.speakers.map { SpeakerHeroUnit(speaker: $0, callback: selectCallback) }
}
