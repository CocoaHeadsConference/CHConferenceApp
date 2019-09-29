//
//  EventMainView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

class EventMainView: CollectionStackView {

    var state: EventMainState = EventMainState() {
        didSet {
            self.container.state = ComposeEventView(with: state, safariCallback: self.didTapSafariCallback)
        }
    }

    var didTapSafariCallback: ((URL)-> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        container.lineSpace = 1
        self.container.alwaysBounceVertical = true
        self.backgroundColor = Theme.shared.mainColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

func ComposeEventView(with state: EventMainState, safariCallback: ((URL)-> Void)?)-> [ComposingUnit] {
    var units: [ComposingUnit] = []
    guard let event = state.event else {
        let empty = EmptyUnit(identifier: "noEvent", text: "Nenhum evento encontrado. \n\nAguarde enquanto estamos atualizando nossos dados.")
        return [empty]
    }
    units.add {
        let headline = LabelUnit(id: "headline", text: event.headline, font: UIFont.systemFont(ofSize: 20, weight: .medium), color: .white, verticalSpace: 16)
        let subline = LabelUnit(id: "subline", text: event.subline, font: UIFont.systemFont(ofSize: 15), color: .white, verticalSpace: 8)
        let mapUnit = MapLocationUnit(location: event.location)
        let dateUnit = EventDateUnit(event: event)
        return [headline, subline, mapUnit, dateUnit]
    }
    units.add(manyIfLet: event.twitterHandle) { twitter in
        let topSpacer = ViewUnit<UIView>(id:"twitter-top", traits:[.height(8)])
        let bottomSpacer = ViewUnit<UIView>(id:"twitter-bottom", traits:[.height(4)])
        let twitterUnit = EventFollowOnTwitterUnit(color: Theme.shared.actionColor, twitter: twitter) {
            guard let url = URL(string:"https://twitter.com/\(twitter)") else {
                return
            }
            safariCallback?(url)
        }
        return [topSpacer, twitterUnit, bottomSpacer]
    }
    units.add(manyIfLet: event.codeOfConductURL) { url in
        let topSpacer = ViewUnit<UIView>(id:"codeConduct-top", traits:[.height(4)])
        let bottomSpacer = ViewUnit<UIView>(id:"codeConduct-bottom", traits:[.height(4)])
        let codeConductUnit = CodeOfConductUnit(color:Theme.shared.actionColor) {
            safariCallback?(url)
        }
        return [topSpacer, codeConductUnit, bottomSpacer]
    }
    return units
}
