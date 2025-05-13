//
//  EventListing.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/11/25.
//

import CoreLocation
import SwiftUI

struct EventListing: View {

  @Environment(\.cloudKitService) var cloudKit

  enum ViewState {
    case loaded([Event])
    case loading
    case error(String)
  }

  @State private var viewState = ViewState.loading

  var body: some View {
    ZStack {
      switch viewState {
      case .loaded(let array):
        List(array) { event in
          NavigationLink {
            EventEditingView(event: event)
          } label: {
            VStack {
              Text(event.title)
              Text(event.page)
                .font(.caption2)
            }
          }
        }
      case .loading:
        ProgressView()
          .task {
            await fetchEvents()
          }
      case .error(let description):
        ContentUnavailableView(
          "Algum erro ocorreu",
          systemImage: "xmark.circle",
          description: Text(description)
        )
      }
    }
    .toolbar {
      NavigationLink {
        EventCreationView()
      } label: {
        Image(systemName: "plus")
      }
    }
  }

  private func fetchEvents() async {
    do {
      let events = try await cloudKit.fetchEventList()
      viewState = .loaded(events)
    } catch {
      viewState = .error(error.localizedDescription)
    }
  }
}

struct EventEditingView: View {
  @Environment(\.cloudKitService) private var cloudKit
  @Environment(\.dismiss) private var dismiss
  @State var event: Event
  @State private var title: String
  @State private var latitude: String
  @State private var longitude: String
  @State private var date: Date
  @State private var rsvpURL: String
  @State private var page: String
  @State private var address: String
  @State private var isSaving = false
  @State private var errorMessage: String?

  init(event: Event) {
    self._event = State(initialValue: event)
    self._title = State(initialValue: event.title)
    self._latitude = State(initialValue: "\(event.location.coordinate.latitude)")
    self._longitude = State(initialValue: "\(event.location.coordinate.longitude)")
    self._date = State(initialValue: event.date)
    self._rsvpURL = State(initialValue: event.rsvpURL.absoluteString)
    self._page = State(initialValue: event.page)
    self._address = State(initialValue: event.address)
  }

  var body: some View {
    Form {
      TextField("Title", text: $title)
      TextField("Address", text: $address)
      TextField("Location (latitude)", text: $latitude)
      TextField("Location (longitude)", text: $longitude)
      DatePicker("Date", selection: $date, displayedComponents: .date)
      TextField("RSVP URL", text: $rsvpURL)
      // TODO: Fill from a list of pages instead of having a string here
      TextField("Page", text: $page)

      if let errorMessage = errorMessage {
        Text(errorMessage)
          .foregroundColor(.red)
          .padding(.top, 10)
      }
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
          Task {
            await saveEvent()
          }
        }
        .disabled(isSaving)
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
    }
    .navigationTitle("Edit Event")
  }

  private func saveEvent() async {
    isSaving = true
    do {
      guard let latitude = Double(latitude),
        let longitude = Double(longitude),
        let url = URL(string: rsvpURL)
      else {
        errorMessage = "Make sure all fields are filled correctly."
        isSaving = false
        return
      }

      let updatedEvent = Event(
        id: event.id,
        title: title,
        address: address,
        location: CLLocation(latitude: latitude, longitude: longitude),
        date: date,
        endDate: date.advanced(by: 3600 * 3),
        rsvpURL: url,
        page: page
      )
      try await cloudKit.updateEvent(updatedEvent)
      dismiss()
    } catch {
      errorMessage = "Failed to save event: \(error.localizedDescription)"
    }
    isSaving = false
  }
}

struct EventCreationView: View {
  @Environment(\.cloudKitService) var cloudKit
  @Environment(\.dismiss) var dismiss
  @State private var title = ""
  @State private var address = ""
  @State private var latitude = ""
  @State private var longitude = ""
  @State private var date = Date()
  @State private var rsvpURL = ""
  @State private var page = ""
  @State private var isSaving = false
  @State private var errorMessage: String?
  @State private var isPrefilling = false
  private let meetupService = MeetupService()

  var body: some View {
    Form {
      TextField("Title", text: $title)
      TextField("Address", text: $address)
      TextField("Location (latitude)", text: $latitude)
      TextField("Location (longitude)", text: $longitude)
      DatePicker("Date", selection: $date, displayedComponents: .date)
      TextField("RSVP URL", text: $rsvpURL)
      TextField("Page", text: $page)

      if let errorMessage = errorMessage {
        Text(errorMessage)
          .foregroundColor(.red)
          .padding(.top, 10)
      }

      Button("Prefill from Meetup") {
        Task {
          await prefillFromMeetup()
        }
      }
      .disabled(isPrefilling || rsvpURL.isEmpty)
      .padding(.top, 10)
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Create") {
          Task {
            await createEvent()
          }
        }
        .disabled(isSaving)
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
    }
    .navigationTitle("Create Event")
  }

  private func prefillFromMeetup() async {
    guard let url = URL(string: rsvpURL) else {
      errorMessage = "Invalid RSVP URL."
      return
    }

    isPrefilling = true
    do {
      let meetupEvent = try await meetupService.event(from: url.absoluteString)
      title = meetupEvent.title
      latitude = "\(meetupEvent.location.coordinate.latitude)"
      longitude = "\(meetupEvent.location.coordinate.longitude)"
      date = meetupEvent.date
      page = meetupEvent.url.absoluteString
      errorMessage = nil
    } catch {
      errorMessage = "Failed to prefill data: \(error.localizedDescription)"
    }
    isPrefilling = false
  }

  private func createEvent() async {
    isSaving = true
    do {
      guard let latitude = Double(latitude),
        let longitude = Double(longitude),
        let url = URL(string: rsvpURL)
      else {
        errorMessage = "Invalid input. Make sure all fields are filled correctly."
        isSaving = false
        return
      }

      let newEvent = Event(
        id: UUID(),
        title: title,
        address: address,
        location: CLLocation(latitude: latitude, longitude: longitude),
        date: date,
        endDate: date.advanced(by: 3600 * 3),
        rsvpURL: url,
        page: page
      )
      try await cloudKit.createEvent(newEvent)
      dismiss()
    } catch {
      errorMessage = "Failed to create event: \(error.localizedDescription)"
    }
    isSaving = false
  }
}
