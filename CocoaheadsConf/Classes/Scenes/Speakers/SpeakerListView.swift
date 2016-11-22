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
class SpeakerListView: NibDesignable {

    @IBOutlet var collectionListView: CollectionStackView! {
        didSet {
            collectionListView.container.direction = .verticalGrid(columns: 3)
            collectionListView.container.sectionInset = UIEdgeInsets(2)
            collectionListView.container.itemSpace = 2
            collectionListView.container.lineSpace = 2
            collectionListView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    var displayCallback: ((SpeakerModel)-> Void)?
    
    var state: SpeakersListState = SpeakersListState(speakers: []) {
        didSet {
            collectionListView.container.state = ComposeSpeakerListView(with: state, selectCallback: displayCallback)
        }
    }
    
}

func ComposeSpeakerListView(with state: SpeakersListState, selectCallback: ((SpeakerModel)-> Void)?)-> [ComposingUnit] {
    return state.speakers.map { SpeakerHeroUnit(speaker: $0, callback: selectCallback) }
}
