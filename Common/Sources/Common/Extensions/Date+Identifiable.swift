//
//  Date+Identifiable.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 07/04/24.
//  Copyright © 2024 Cocoaheadsbr. All rights reserved.
//

import Foundation

extension Date: Identifiable {
  public var id: String {
    ISO8601Format()
  }
}
