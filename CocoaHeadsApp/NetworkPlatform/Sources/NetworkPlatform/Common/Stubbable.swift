//
//  Stubbable.swift
//  NetworkPlatform
//
//  Created by Rokon on 24/01/2024.
//  Copyright © 2024 MLBD. All rights reserved.
//

import Foundation

protocol Stubble {

}

extension Stubble {
  func stubbedResponse(_ filename: String) -> Data! {
    let path = Bundle.module.path(
      forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
  }
}
