//
//  UIColor+Hex.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import SwiftUI

extension Color {
  public init(hex: String) {
    let scanner = Scanner(string: hex.trimmingCharacters(in: .alphanumerics.inverted))
    scanner.currentIndex = scanner.string.startIndex
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)

    let r = (rgbValue & 0xff0000) >> 16
    let g = (rgbValue & 0xff00) >> 8
    let b = rgbValue & 0xff
    self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
  }
}
