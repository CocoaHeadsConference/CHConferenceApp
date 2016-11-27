//
//  Theme.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 24/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

class Theme: Unmarshaling {

    static let shared = Theme()
    
    var mainColor: UIColor = UIColor(hexString: "16a085")
    var contrastingColor: UIColor = .white
    var shadowColor: UIColor = .black
    var actionColor: UIColor = UIColor(hexString: "1abc9c")
    
    init() {
        
    }
    
    required init(object: MarshaledObject) throws {
        let main: String = try object.value(for: "main")
        let contrasting: String = try object.value(for: "contrasting")
        let shadow: String = try object.value(for: "shadow")
        let action: String = try object.value(for: "action")
        mainColor = UIColor(hexString: main)
        contrastingColor = UIColor(hexString: contrasting)
        shadowColor = UIColor(hexString: shadow)
        actionColor = UIColor(hexString: action)
    }
    
    func apply(theme: Theme) {
        contrastingColor = theme.contrastingColor
        mainColor = theme.mainColor
        shadowColor = theme.shadowColor
        actionColor = theme.actionColor
    }
    
}
