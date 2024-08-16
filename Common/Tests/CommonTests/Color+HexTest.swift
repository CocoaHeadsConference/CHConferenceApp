//
//  Color+HexTest.swift
//  Common
//
//  Created by Mauricio Cardozo on 04/08/24.
//

import SwiftUI
import Testing

@Suite("Hex string to SwiftUI Color conversion")
struct ColorHexTests {

  @Test("converts hex to Color")
  func hexToColorConversion() {
    let redColor = Color(hex: "#FF0000")
    let blueColor = Color(hex: "00FF00")
    let greenColor = Color(hex: "#0000FF#")

    #expect(UIColor(redColor).description == "UIExtendedSRGBColorSpace 1 0 0 1")
    #expect(UIColor(blueColor).description == "UIExtendedSRGBColorSpace 0 1 0 1")
    #expect(UIColor(greenColor).description == "UIExtendedSRGBColorSpace 0 0 1 1")
  }
}
