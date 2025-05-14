//
//  Bundle+AppClip.swift
//  Common
//
//  Created by Mauricio on 5/9/25.
//

import Foundation
import UIKit

extension UIApplication {
  public var isAppClip: Bool {
    Bundle.main.isAppClip
  }
}

extension Bundle {
  var isAppClip: Bool {
    infoDictionary?["NSAppClip"] != nil
  }
}
