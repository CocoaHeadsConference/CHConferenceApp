//
//  MeetupDebugging.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import CocoaHeadsCore
import SwiftUI

struct MeetupDebugging: View {

  @State private var isLoading = false
  @State private var eventTitle: String = ""
  @State private var eventDate: String = ""
  @State private var eventLocation: String = ""
  @State private var eventDescription: String = ""
  @State private var eventRSVPLink: String = ""
  @State private var meetupEvent: MeetupEvent?
  @State private var textField: String = ""

  var body: some View {
    List {
      Section {
        TextField("Paste meetup link here", text: $textField)
        Button("Add example meetup link") {
          textField =
            "https://www.meetup.com/pt-BR/swift-language/events/307194649/?eventOrigin=home_page_upcoming_events$all"
        }
        Button("Add example cocoaheads meetup link") {
          textField = "https://www.meetup.com/cocoaheadssp/events/307551844/?eventOrigin=group_upcoming_events"
        }

        Button("Scrape Event Data") {
          Task {
            isLoading = true
            meetupEvent = nil
            eventTitle = ""
            await scrapeEvent()
            isLoading = false
          }
        }

        if let meetupEvent {
          NavigationLink("Event detail screen for this meetup") {
            EventDetail(
              title: meetupEvent.title,
              image: meetupEvent.image,
              imageID: nil,
              ui: meetupEvent.ui,
              shareURL: meetupEvent.url
            )
          }
        }

        if isLoading {
          Text("Loading")
            .font(.caption)
        }

        if eventTitle.contains("error") {
          Text(eventTitle)
        }

        if let meetupEvent {
          Text("Event Title: \(eventTitle)")
          Text("Event Date: \(eventDate)")
          Text("Location: \(eventLocation)")
          Text("Description: \(eventDescription)")
          Text("RSVP Link: \(eventRSVPLink)")

          VStack {
            AsyncImage(
              url: meetupEvent.image,
              scale: 2
            ) {
              $0
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
            } placeholder: {
              Rectangle()
                .fill(.tertiary)
                .frame(minHeight: 150)
            }
            .mask {
              RoundedRectangle(cornerRadius: 10, style: .continuous)
            }
            .padding()
          }
        }
      }
    }
    .animation(.default, value: meetupEvent)
  }

  func scrapeEvent() async {
    do {
      let meetup = MeetupService()
      let event = try await meetup.event(from: textField)
      eventTitle = event.title
      eventDate = event.date.formatted()
      eventLocation =
        event.address + "\nlat: \(event.location.latitude) lng: \(event.location.longitude)"
      eventDescription = event.description
      eventRSVPLink = event.url.absoluteString
      meetupEvent = event
    } catch {
      eventTitle =
        if let error = error as? MeetupError {
          error.localizedDescription
        } else {
          "error: \(error)"
        }
    }
  }
}
