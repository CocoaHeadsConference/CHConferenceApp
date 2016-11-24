//
//  SponsorsListView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 22/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

class SponsorsListView: CollectionStackView {

    var state: SponsorsListState = SponsorsListState(sponsors: []) {
        didSet {
            self.container.state = ComposeSponsorsList(with: state)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .clear
        self.container.direction = .vertical
        self.container.lineSpace = 2
        self.container.sectionInset = UIEdgeInsets(vertical: 4)
    }
    
}


func ComposeSponsorsList(with state: SponsorsListState)-> [ComposingUnit] {
    return state.sponsors.map { ListDetailUnit(for: $0) }
}

