//
//  PreviewDevice+Devices.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/31/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

extension PreviewDevice {
    static var iPhone11: PreviewDevice {
        PreviewDevice(rawValue: "iPhone 11")
    }

    static var iPhoneSE: PreviewDevice {
        PreviewDevice(rawValue: "iPhone SE")
    }

    static var iPadPro11: PreviewDevice {
        PreviewDevice(rawValue: "iPad Pro (11-inch)")
    }
}
