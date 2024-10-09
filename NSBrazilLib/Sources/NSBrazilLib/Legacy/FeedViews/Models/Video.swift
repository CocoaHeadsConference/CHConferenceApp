//
//  Video.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

struct Video: Codable, Identifiable {
  private(set) var id = UUID()
  let title: String
  let speaker: String
  let background: URL
  let link: URL

  var backgroundColor: Color {
    Color(.background10)
  }
}
