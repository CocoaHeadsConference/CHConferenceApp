//
//  Config.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import StoreKit

struct Config {
  @MainActor
  private(set) static var isTestflightOrDebug = false

  @MainActor
  static func fetchEnvironment() async {
    do {
      let transaction = try await AppTransaction.shared
      switch transaction {
      case .unverified(let signedType, _):
        isTestflightOrDebug = signedType.environment != .production
      case .verified(let signedType):
        isTestflightOrDebug = signedType.environment != .production
      }
    } catch {
      var isSimulatorOrTestFlight: Bool {
        #if targetEnvironment(simulator)
          return true
        #else
          guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
          }
          return receiptURL.lastPathComponent == "sandboxReceipt"
        #endif
      }
      isTestflightOrDebug = isSimulatorOrTestFlight
    }
  }
}
