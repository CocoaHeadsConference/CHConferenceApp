//
//  Color+Case.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 1/18/21.
//  Copyright © 2021 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: This is probably obsolete because of the new Xcode Assets

enum NSColors: String {
    case background
    case ctaBackground = "cta-background"
    case buttonBackground
    case background10
}

extension Color {
    init(_ color: NSColors) {
        // calling Color's init directly couldn't set the right color for the colorScheme when running in an app clip
        // only happens when running directly on device!
        self.init(UIColor(named: color.rawValue)!)
    }
}
