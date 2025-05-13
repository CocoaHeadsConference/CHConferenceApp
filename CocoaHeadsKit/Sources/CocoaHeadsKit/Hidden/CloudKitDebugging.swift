//
//  CloudKitDebugging.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import SwiftUI

struct CloudKitDebugging: View {

  @State private var recordName: String = ""
  @State private var hasAccess: String = ""

  @Environment(\.cloudKitService) var cloudKit

  var body: some View {
    List {
      Section {
        Text("id: \(recordName)")
        Text("is chapter leader: \(hasAccess)")
        Button("Copy ID") {
          UIPasteboard.general.string = recordName
        }
      }
    }
    .task {
      async let name: Void = fetchRecordName()
      async let access: Void = fetchLeaderAccess()
      let _ = await [name, access]
    }
  }

  func fetchRecordName() async {
    do {
      let id = try await cloudKit.fetchUserRecordID()
      recordName = id
    } catch {
      recordName = "fetch error - are you logged in icloud?"
    }
  }

  func fetchLeaderAccess() async {
    do {
      let hasLeaderAccess = try await cloudKit.fetchLeaderAccess()
      hasAccess = hasLeaderAccess ? "yes" : "no?"
    } catch {
      hasAccess = "no"
    }
  }
}
