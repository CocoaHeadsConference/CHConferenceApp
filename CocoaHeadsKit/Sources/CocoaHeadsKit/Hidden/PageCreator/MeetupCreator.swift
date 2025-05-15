//
//  MeetupCreator.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/14/25.
//

import SwiftUI

struct MeetupSpeaker: Identifiable, Equatable {
  var id: String { name }
  var name: String
  var talk: String
  var links: [String: URL]
}

struct MeetupCreator: View {

  @Binding var ui: [UI]

  @State private var isLoading = false
  @State private var meetupURL: String = ""
  @State private var meetupEvent: MeetupEvent?
  @State private var description: String = ""
  @State private var social: URL?

  @State private var speakerName = ""
  @State private var speakerTalk = ""
  @State private var speakerURL = ""
  @State private var speakerURLTitle = ""

  @State private var speakers: [MeetupSpeaker] = []

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

        if isLoading {
          Text("Loading")
            .font(.caption)
        }
      }

      meetupEventSection
    }
    .toolbar {
      Button("Done") {
        guard let meetupEvent else { return }
        ui = [
          .eventDetail(
            meetupEvent.ui(
              customDescription: description,
              withExtraSocial: social,
              speakers: speakersCard
            )
          )
        ]

        dismiss()
      }
      .disabled(meetupEvent == nil)
    }
  }

  @ViewBuilder var meetupEventSection: some View {
    previewSection
    customizeDescriptionSection
    addSpeakersSection
    speakerListSection
  }

  @ViewBuilder var previewSection: some View {
    if let meetupEvent {
      Section("Preview") {
        NavigationLink("Preview") {
          EventDetail(
            title: meetupEvent.title,
            image: meetupEvent.image,
            imageID: nil,
            ui: meetupEvent.ui(
              customDescription: description,
              withExtraSocial: social,
              speakers: speakersCard
            ),
            shareURL: meetupEvent.url
          )
        }
      }
    }
  }

  @ViewBuilder var customizeDescriptionSection: some View {
    if meetupEvent != nil {
      Section("Customize description") {
        TextField("Descrição", text: $description, axis: .vertical)
      }
    }
  }

  // TODO: Create a decent UX for this eventually
  @ViewBuilder var addSpeakersSection: some View {
    if meetupEvent != nil {
      Section("Add Speakers") {
        TextField("Name", text: $speakerName)
        TextField("Talk", text: $speakerTalk)

        Button("Add Speaker") {
          speakers.append(
            MeetupSpeaker(name: speakerName, talk: speakerTalk, links: [:])
          )

          speakerName = ""
          speakerTalk = ""
          speakerURL = ""
        }
      }
    }
  }

  @ViewBuilder var speakerListSection: some View {
    if meetupEvent != nil {
      if !speakers.isEmpty {
        Section("Speakers") {
          ForEach(speakers) { speaker in
            VStack(alignment: .leading) {
              Text("Name: \(speaker.name)")
              Text("Talk: \(speaker.talk)")
              ForEach(Array(speaker.links.keys), id: \.self) { link in
                Text(
                  link.isEmpty
                    ? "link added"
                    : link
                )
              }

              TextField("Link", text: $speakerURL)
              TextField("Link Title", text: $speakerURLTitle)
              Spacer()
              Button("Add Link (Yes I know this is bad UX)") {
                addURLToSpeaker(speaker)
              }
              .buttonStyle(.borderedProminent)
            }
          }
        }
      }
    }
  }

  var speakersCard: EventDetailUI {
    guard !speakers.isEmpty else { return .empty }

    let meetupSpeakers = speakers.flatMap { speaker in
      [
        EventDetailUI.speaker(name: speaker.name, talk: speaker.talk),
        EventDetailUI.carousel(
          ui: speaker.links.map {
            .link($0.value, title: $0.key)
          }
        )
      ]
    }

    return if meetupSpeakers.isEmpty {
      .empty
    } else {
      .card(
        title: "Talks & Palestrantes",
        ui: meetupSpeakers)
    }
  }

  func addURLToSpeaker(_ speaker: MeetupSpeaker) {
    guard
      let url = URL(string: speakerURL),
      let index = speakers.firstIndex(where: { $0 == speaker })
    else { return }
    let title =
      speakerURLTitle.isEmpty
      ? url.host() ?? "unknown host"
      : speakerURLTitle

    speakers[index].links[title] = url
    speakerURL = ""
    speakerURLTitle = ""
  }

  func scrapeEvent() async {
    do {
      let meetup = MeetupService()
      let event = try await meetup.event(from: meetupURL)
      meetupEvent = event
      description = event.description
      if description.lowercased().contains("campinas"),
        let url = URL(string: "https://instagram.com/cocoaheads.cps")
      {
        social = url
      }
    } catch {
      // TODO: Alert?
    }
  }
}
