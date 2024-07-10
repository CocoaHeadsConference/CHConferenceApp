//
//  BuildConfiguration.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Foundation

public class BuildConfiguration {
  struct Configuration: Decodable {
    let name: String
    let baseURL: String
    let testFlags: TestFlags?
  }

  struct TestFlags: Decodable {
    let resetData: Bool
    let noSplash: Bool
    let applyTestData: Bool
  }

  // MARK: Shared instance
  public static let shared = BuildConfiguration()

  // MARK: Properties
  private let configuration: Configuration

  // MARK: Lifecycle

  private init(name: String = "BuildConfiguration.plist") {
    guard let filePath = Bundle.main.path(forResource: name, ofType: nil),
      let fileData = FileManager.default.contents(atPath: filePath)
    else {
      fatalError("Configuration file '\(name)' not loadable!")
    }

    do {
      configuration = try PropertyListDecoder().decode(
        Configuration.self, from: fileData)

    } catch {
      fatalError("Configuration not decodable from '\(name)': \(error)")
    }
  }

  public var baseURLString: String {
    return configuration.baseURL
  }

  public var configName: String {
    return configuration.name
  }
}
