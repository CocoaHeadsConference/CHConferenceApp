//
//  Image+SFSymbols.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 1/18/21.
//  Copyright © 2021 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

enum SystemImage: String {
    case linkCircle = "link.circle"
}

extension Image {
    init(_ image: SystemImage) {
        self.init(systemName: image.rawValue)
    }
}
