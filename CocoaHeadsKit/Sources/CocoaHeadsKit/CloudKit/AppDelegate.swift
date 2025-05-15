//
//  AppDelegate.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/15/25.
//

import CloudKit
import UIKit

public final class AppDelegate: NSObject, UIApplicationDelegate {
  public func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
      NotificationCenter.default.post(name: .cloudKitRemoteNotificationReceived, object: notification)
      completionHandler(.newData)
    } else {
      print("didReceiveRemoteNotification error")
      completionHandler(.noData)
    }
  }
}
