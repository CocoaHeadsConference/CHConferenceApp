//
//  EventEditingView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/14/25.
//

import CoreLocation
import PhotosUI
import SwiftUI

// TODO: Merge these two together once we're TCA
// TODO: Break the sub sections into smaller views
// MARK: - Editing

enum ImageState {
  case success(Image)
  case loading(Progress)
  case failure(Error)
  case empty
}

struct ImageStateView: View {
  let state: ImageState

  var body: some View {
    VStack {
      switch state {
      case .success(let image):
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 200)

      case .loading(let progress):
        ProgressView(value: progress.fractionCompleted)
      case .failure(let error):
        Text(error.localizedDescription)
      case .empty:
        Text("No image selected")
      }
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

  @State private var imageState: ImageState = .empty
  @State private var imageSelection: PhotosPickerItem?

  private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
    return imageSelection.loadTransferable(type: TicketImage.self) { result in
      DispatchQueue.main.async {
        guard imageSelection == self.imageSelection else {
          print("Failed to get the selected item.")
          return
        }
        switch result {
        case .success(let ticketImage?):
          self.imageState = .success(ticketImage.image)
        case .success(nil):
          self.imageState = .failure(NSError(domain: "Failed to decode image", code: 0))
        case .failure(let error):
          self.imageState = .failure(error)
        }
      }
    }
  }

  var body: some View {
    Form {
      TextField("Title", text: $title)
      TextField("Address", text: $address)
      TextField("Location (latitude)", text: $latitude)
      TextField("Location (longitude)", text: $longitude)
      DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
      TextField("RSVP URL", text: $rsvpURL)
      NavigationLink(
        page.isEmpty
          ? "Select page"
          : page
      ) {
        PageListing { pageTitle in
          page = pageTitle
        }
      }
      PhotosPicker("Image", selection: $imageSelection, matching: .images, photoLibrary: .shared())
        .onChange(of: imageSelection) {
          if let imageSelection {
            let progress = loadTransferable(from: imageSelection)
            imageState = .loading(progress)
          } else {
            imageState = .empty
          }
        }
      ImageStateView(state: imageState)

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
    .task {
      await fetchCurrentImage()
    }
  }

  func fetchCurrentImage() async {
    do {
      guard
        let asset = try await cloudKit.fetchImageAsset(for: event),
        let uiImage = UIImage(data: asset)
      else {
        return
      }

      imageState = .success(Image(uiImage: uiImage))
    } catch {

    }
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

      var updatedEvent = Event(
        id: event.id,
        title: title,
        address: address,
        location: CLLocation(latitude: latitude, longitude: longitude),
        date: date,
        endDate: date.advanced(by: 3600 * 3),
        rsvpURL: url,
        page: page
      )

      if case .success(let image) = imageState {
        updatedEvent.image = try? await image.exported(as: .jpeg)
      }

      try await cloudKit.updateEvent(updatedEvent)
      dismiss()
    } catch {
      errorMessage = "Failed to save event: \(error.localizedDescription)"
    }
    isSaving = false
  }
}

// MARK: - Creation

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
  @State private var imageState: ImageState = .empty
  private let meetupService = MeetupService()

  var body: some View {
    Form {
      Section {
        TextField("RSVP URL", text: $rsvpURL)
        Button("Prefill from Meetup URL") {
          Task {
            await prefillFromMeetup()
          }
        }
        .disabled(isPrefilling || rsvpURL.isEmpty)
        .padding(.top, 10)
      }
      Section {
        TextField("Title", text: $title)
        TextField("Address", text: $address)
        TextField("Location (latitude)", text: $latitude)
        TextField("Location (longitude)", text: $longitude)
        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])

        NavigationLink(
          page.isEmpty
            ? "Select page"
            : page
        ) {
          PageListing { pageTitle in
            page = pageTitle
          }
        }

        ImageStateView(state: imageState)
      }

      if let errorMessage = errorMessage {
        Section {
          Text(errorMessage)
            .foregroundColor(.red)
            .padding(.top, 10)
        }
      }
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
      address = meetupEvent.address
      latitude = "\(meetupEvent.location.coordinate.latitude)"
      longitude = "\(meetupEvent.location.coordinate.longitude)"
      date = meetupEvent.date
      errorMessage = nil

      if let imageURL = meetupEvent.image {
        imageState = .loading(.init())
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        if let uiImage = UIImage(data: data) {
          imageState = .success(Image(uiImage: uiImage))
        } else {
          imageState = .failure(NSError(domain: "Failed to decode image", code: 0))
        }
      } else {
        imageState = .failure(NSError(domain: "No image found on Meetup", code: 0))
      }

    } catch {
      errorMessage = "Failed to fill with data from Meetup: \(error.localizedDescription)"
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

      var newEvent = Event(
        id: UUID(),
        title: title,
        address: address,
        location: CLLocation(latitude: latitude, longitude: longitude),
        date: date,
        endDate: date.advanced(by: 3600 * 3),
        rsvpURL: url,
        page: page
      )

      if case .success(let image) = imageState {
        newEvent.image = try? await image.exported(as: .jpeg)
      }

      try await cloudKit.createEvent(newEvent)
      dismiss()
    } catch {
      errorMessage = "Failed to create event: \(error.localizedDescription)"
    }
    isSaving = false
  }
}
