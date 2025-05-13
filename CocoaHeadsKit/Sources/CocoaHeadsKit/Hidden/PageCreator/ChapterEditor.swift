//
//  ChapterEditor.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/13/25.
//

import SwiftUI

// TODO: Actually make this an editor

struct ChapterEditor: View {

  @Environment(\.cloudKitService) var cloudKit

  @State private var selectedChapter: Chapter?
  @State private var selectedEvent: Event?
  @State private var isPickingChapter = false
  @State private var isPickingEvent = false
  @State private var isSaving = false
  @State private var error: String?

  var body: some View {
    List {
      Section {
        Button("Pick a chapter") {
          isPickingChapter = true
        }
      }
      .onChange(of: selectedChapter) {
        isPickingChapter = false
        selectedEvent = nil
      }
      .sheet(isPresented: $isPickingChapter) {
        ChapterPicker(chapter: $selectedChapter)
      }

      if let selectedChapter {
        options(for: selectedChapter)
      }

      if let selectedEvent {
        options(for: selectedEvent)
      }
    }
    .toolbar {
      Button {
        Task {
          await addEventToChapter()
        }
      } label: {
        if isSaving {
          ProgressView()
        } else {
          Text("Save")
        }
      }
      .disabled(selectedEvent == nil)
    }
  }

  @ViewBuilder func options(for chapter: Chapter) -> some View {
    Section("Chapter") {
      Text("id: \(chapter.id.uuidString)")
      Text("title: \(chapter.title)")

      Button("Pick event") {
        isPickingEvent = true
      }
      .onChange(of: selectedEvent) {
        isPickingEvent = false
      }
      .sheet(isPresented: $isPickingEvent) {
        EventListing { event in
          selectedEvent = event
        }
      }
    }
  }

  @ViewBuilder func options(for event: Event) -> some View {
    Section("Event") {
      Text("id \(event.id.uuidString)")
      Text("title: \(event.title)")
      Text("slug: \(event.page)")
      // TODO: When we have TCA, add an option to open the event editing view from here
    }
  }

  func addEventToChapter() async {
    guard let selectedChapter, let selectedEvent else { return }
    isSaving = true
    do {
      try await cloudKit.update(selectedChapter, byAdding: selectedEvent)
    } catch {
      // TODO: Alert?
    }
    isSaving = false
  }
}
