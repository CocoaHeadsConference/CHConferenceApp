//
//  TalkDetailView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 18/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import NibDesignable
import Compose

class TalkDetailView: CollectionStackView {
    
    var didTapGoBackCallback: (()-> Void)?
    var didTapPlayCallback: (()-> Void)?
    var state: TalkDetailViewState = TalkDetailViewState() {
        didSet {
            self.backgroundColor = state.talk?.type.color
            container.state = ComposeTalkDetailView(with: state, goBackCallback: self.goBack, playVideoCallback: self.playVideo)
        }
    }
    
    func goBack() {
        didTapGoBackCallback?()
    }
    
    func playVideo() {
        didTapPlayCallback?()
    }
    
}


func ComposeTalkDetailView(with state: TalkDetailViewState, goBackCallback: (()-> Void)?, playVideoCallback: (()-> Void)?)-> [ComposingUnit] {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, HH:mm"
    var units: [ComposingUnit] = []
    guard let talk = state.talk else { return units }
    units.add {
        let header = TalkDetailUnits.Header(for: talk, goBack: goBackCallback)
        let desc = TalkDetailUnits.Description(for: talk)
        return [header, desc]
    }
    units.add(ifLet: talk.video) { _ in
        return TalkDetailUnits.Play(playHandler: playVideoCallback)
    }
    units.add {
        let spacer = TalkDetailUnits.Spacer(with: "upperSpacer")
        let stats = TalkDetailUnits.Stats(for: talk)
        return [spacer, stats]
    }
    return units
}
