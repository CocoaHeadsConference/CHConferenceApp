//
//  Theme.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 24/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class Theme{ //Codable {
//
//    static let shared = Theme()
//
//    var mainColor: UIColor = UIColor(hexString: "16a085")
//    var contrastingColor: UIColor = .white
//    var shadowColor: UIColor = .black
//    var actionColor: UIColor = UIColor(hexString: "1abc9c")
//    var talkColor = UIColor(hexString: "D84315")
//    var workshopColor = UIColor(hexString: "00838F")
//    var openingColor = UIColor(hexString: "AD1457")
//    var closingColor = UIColor(hexString: "AD1457")
//    var breaktimeColor = UIColor(hexString: "F9A825")
//    var setupColor = UIColor(hexString: "9E9D24")
//
//
//    let main: String
//    let contrastingColor:String
//    case shadowColor = "shadow"
//    case actionColor = "action"
//    case talkColor = "talk"
//    case workshopColor = "workshop"
//    case openingColor = "opening"
//    case closingColor = "closing"
//    case breaktimeColor = "breaktime"
//    case setupColor = "setup"
//
//    init() {
//
//    }
//
//    func apply(theme: Theme) {
//        contrastingColor = theme.contrastingColor
//        mainColor = theme.mainColor
//        shadowColor = theme.shadowColor
//        actionColor = theme.actionColor
//        talkColor = theme.talkColor
//        workshopColor = theme.workshopColor
//        openingColor = theme.openingColor
//        closingColor = theme.closingColor
//        breaktimeColor = theme.breaktimeColor
//        setupColor = theme.setupColor
//    }
//
}


extension Theme {
    enum CodingKeys: String, CodingKey {
            case mainColor = "main"
            case contrastingColor = "contrasting"
            case shadowColor = "shadow"
            case actionColor = "action"
            case talkColor = "talk"
            case workshopColor = "workshop"
            case openingColor = "opening"
            case closingColor = "closing"
            case breaktimeColor = "breaktime"
            case setupColor = "setup"
    }
}
