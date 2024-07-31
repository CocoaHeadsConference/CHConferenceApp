//
//  Sponsor.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Common
import Foundation
import SwiftUI

struct Sponsor: Codable, Identifiable {
    let name: String
    let link: URL
    let image: URL
    let backgroundColor: String
    
    var id: String {
        name
    }

    var logo: UIImage {
        return UIImage(named: "ic_merc_livre") ?? UIImage()
    }
    
    var background: Color {
        return Color(UIColor(hexString: backgroundColor))
    }
}
