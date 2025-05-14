//
//  Debug.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/1/25.
//

// TODO: Create a way for chapter leaders to create events on the app

import SwiftUI

struct Debug: View {

  @State private var shouldShowPrivateSections = false

  @Environment(\.cloudKitService) var cloudKit

  var body: some View {
    List {
      Section {
        NavigationLink("CloudKit") {
          CloudKitDebugging()
        }
      }
      if shouldShowPrivateSections {
        Section {
          NavigationLink("Meetup Parser") {
            MeetupDebugging()
          }
          NavigationLink("Event Detail UI Storybook") {
            EventDetailUIViewer()
          }
          NavigationLink("All pages") {
            PageListing()
          }
          NavigationLink("Page creator") {
            PageCreator()
          }
          NavigationLink("All Events") {
            EventListing()
          }
          NavigationLink("Link events to chapters") {
            ChapterEditor()
          }
        }
      }
    }
    .navigationTitle("top secret 👻")
    .task {
      do {
        shouldShowPrivateSections = try await cloudKit.fetchLeaderAccess()
      } catch {}
    }
    .animation(.default, value: shouldShowPrivateSections)
  }
}

#Preview {
  Debug()
}
