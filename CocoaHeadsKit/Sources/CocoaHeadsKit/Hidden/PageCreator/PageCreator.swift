//
//  Creator.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import SwiftUI

struct PageCreator: View {

  enum Sheet: String, Identifiable {
    case chapterPicker
    case meetupScraper
    case templatePicker
    case createUIFromScratch

    var id: String { rawValue }
  }

  @State private var chapter: Chapter?
  @State private var textField: String = ""
  @State private var sheetState: Sheet?
  @State private var isLoading = false
  @State private var ui: [UI] = []
  @Environment(\.cloudKitService) var cloudKit
  @Environment(\.dismiss) var dismiss

  var body: some View {
    List {
      Section("Chapter") {
        Button(chapter?.title ?? "Pick a chapter") {
          sheetState = .chapterPicker
        }
      }

      Section("Title") {
        TextField("Write a page title", text: $textField)
      }

      Section("Content") {
        Button("Fetch from Meetup.com") {
          sheetState = .meetupScraper
        }

        Button("Use a pre-made template") {
          sheetState = .templatePicker
        }

        Button("Create from scratch") {
          sheetState = .createUIFromScratch
        }

        if !ui.isEmpty {
          Text("Content is loaded")
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          Task {
            await savePage()
          }
        } label: {
          if isLoading {
            ProgressView()
          } else {
            Text("Save")
          }
        }
        .disabled(!canSave)
      }
    }
    .sheet(item: $sheetState) { sheet in
      switch sheet {
      case .chapterPicker:
        ChapterPicker(chapter: $chapter)
      case .meetupScraper:
        NavigationStack {
          MeetupCreator(ui: $ui)
        }
      case .templatePicker:
        VStack {
          Text("TO-DO: Build a bunch of templates and allow leaders to pick from them")
          Button("Add a mock") {
            ui = [.eventDetail(Event.mock.ui)]
            sheetState = nil
            textField = Event.mock.title
          }
        }
      case .createUIFromScratch:
        Text("TO-DO: Build a UI creator")
      }
    }
    .alert(error, isPresented: $isAlertPresented) {
      Button("OK") {
        isAlertPresented = false
      }
    }
  }

  @State private var isAlertPresented = false
  @State private var error: String = ""

  private var canSave: Bool {
    !textField.isEmpty && !ui.isEmpty
  }

  func savePage() async {
    guard canSave else { return }
    // TODO: guard for empty slug and ui
    isLoading = true
    do {
      let chapterTitle =
        if let chapterTitle = chapter?.title {
          "\(chapterTitle)/"
        } else {
          ""
        }

      let slug = (chapterTitle + textField).cleanAndLowercased()
        .replacingOccurrences(of: "º", with: "")

      try await cloudKit.createPage(slug: slug, ui: ui)
      // TODO: When this is TCA, display success notification after dismiss
      dismiss()
    } catch {
      isAlertPresented = true
      self.error = error.localizedDescription
      dump(error)
    }
    isLoading = false
  }
}

// TODO: Move to a separate file
extension String {
  func cleanAndLowercased() -> String {
    lowercased()
      .trim()
      .folding(options: .diacriticInsensitive, locale: .current)
      .replacingOccurrences(of: " ", with: "")
  }
}

struct MeetupCreator: View {

  @Binding var ui: [UI]

  @State private var isLoading = false
  @State private var meetupURL: String = ""
  @State private var meetupEvent: MeetupEvent?
  @State private var description: String = ""

  @Environment(\.dismiss) var dismiss

  var body: some View {
    List {
      Section("Meetup") {
        TextField("Paste Meetup URL here", text: $meetupURL)
        Button("Scrape Event Data") {
          Task {
            isLoading = true
            meetupEvent = nil
            await scrapeEvent()
            isLoading = false
          }
        }
      }

      Section("Data") {
        if isLoading {
          Text("Loading")
            .font(.caption)
        }

        if let meetupEvent {
          NavigationLink("Preview") {
            EventDetail(
              title: meetupEvent.title,
              image: meetupEvent.image,
              imageID: nil,
              ui: meetupEvent.ui(customDescription: description),
              shareURL: meetupEvent.url
            )
          }

          TextField("Descrição", text: $description, axis: .vertical)

          // TODO: Add speakers
          Text("TO-DO: Uma forma de adicionar speakers, talks e links deles")
        }
      }
    }
    .toolbar {
      Button("Done") {
        guard let meetupEvent else { return }
        ui = [
          .eventDetail(meetupEvent.ui)
        ]

        dismiss()
      }
      .disabled(meetupEvent == nil)
    }
  }

  func scrapeEvent() async {
    do {
      let meetup = MeetupService()
      let event = try await meetup.event(from: meetupURL)
      meetupEvent = event
      description = event.description
    } catch {
      // TODO: Alert?
    }
  }
}
