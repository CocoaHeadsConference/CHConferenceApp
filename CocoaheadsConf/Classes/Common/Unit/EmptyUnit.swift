//
//  EmptyUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

func EmptyUnit(identifier: String,text: String)-> ComposingUnit {
    return ViewUnit<UILabel>(id: identifier, traits: [ .height(DimensionUnit(minusHeight: 114)), .insets(UIEdgeInsets(horizontal: 16)) ]) { label in
        label.superview?.backgroundColor = Theme.shared.shadowColor.withAlphaComponent(0.2)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = text
    }
}
