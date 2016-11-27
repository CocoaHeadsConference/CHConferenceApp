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
    var talkColor = UIColor(hexString: "D84315")
    var workshopColor = UIColor(hexString: "00838F")
    var openingColor = UIColor(hexString: "AD1457")
    var closingColor = UIColor(hexString: "AD1457")
    var breaktimeColor = UIColor(hexString: "F9A825")
    var setupColor = UIColor(hexString: "9E9D24")
    
    init() {
        
    }
    
    required init(object: MarshaledObject) throws {
        let main: String = try object.value(for: "main")
        let contrasting: String = try object.value(for: "contrasting")
        let shadow: String = try object.value(for: "shadow")
        let action: String = try object.value(for: "action")
        let talk: String = try object.value(for: "talk")
        let workshop: String = try object.value(for: "workshop")
        let opening: String = try object.value(for: "opening")
        let closing: String = try object.value(for: "closing")
        let breaktime: String = try object.value(for: "breaktime")
        let setup: String = try object.value(for: "setup")
        mainColor = UIColor(hexString: main)
        contrastingColor = UIColor(hexString: contrasting)
        shadowColor = UIColor(hexString: shadow)
        actionColor = UIColor(hexString: action)
        talkColor = UIColor(hexString: talk)
        workshopColor = UIColor(hexString: workshop)
        openingColor = UIColor(hexString: opening)
        closingColor = UIColor(hexString: closing)
        breaktimeColor = UIColor(hexString: breaktime)
        setupColor = UIColor(hexString: setup)
    }
    
    func apply(theme: Theme) {
        contrastingColor = theme.contrastingColor
        mainColor = theme.mainColor
        shadowColor = theme.shadowColor
        actionColor = theme.actionColor
        talkColor = theme.talkColor
        workshopColor = theme.workshopColor
        openingColor = theme.openingColor
        closingColor = theme.closingColor
        breaktimeColor = theme.breaktimeColor
        setupColor = theme.setupColor
    }
    
}
