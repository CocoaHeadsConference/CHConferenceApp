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

    var state: EventMainState = EventMainState()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        container.lineSpace = 1
        self.backgroundColor = UIColor(hexString: "004D40")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
