//
//  Ticket.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/1/25.
//

import SwiftUI

// TODO: Make this view modular/server-driven

struct Ticket: View {

  var imageURL: URL?
  @State private var imageData: Data?
  let event: Event

  @Environment(\.cloudKitService) var cloudKit

  @ViewBuilder
  var image: some View {
    ZStack {
      if let imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
      } else {
        AsyncImage(url: imageURL, scale: 2)
      }
    }
    .task {
      guard imageURL == nil else { return }

      do {
        imageData = try await cloudKit.fetchImageAsset(for: event)
      } catch {
        print(error)
      }
    }
  }

  var body: some View {
    TicketCard {
      header
        .padding()

      image
        .aspectRatio(contentMode: .fill)
        .frame(height: 150)
        .clipped()

      eventDetails
        .padding()

      Line()
        .stroke(
          style: .init(
            lineWidth: 2,
            lineCap: .square,
            dash: [5, 10]
          )
        )
        .fill(.black.opacity(0.1))
        .frame(height: 1)

      VStack {
        Barcode(text: event.title)
          .frame(height: 100)
          .overlay {
            Text("Não será permitida a entrada sem inscrição!")
              .font(.caption)
              .fontDesign(.monospaced)
              .italic()
              .foregroundStyle(.secondary)
              .offset(y: 47)
          }
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom)
    }
  }

  private var header: some View {
    HStack {
      // This should be dynamic for each location
      // CocoaHeads Fortaleza uses a different logo
      Image(.logo)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 38, height: 38)

      Spacer()

      VStack(alignment: .trailing) {
        Text("Data")
          .font(.caption)
        Text(
          event.endDate.formatted(
            Date.FormatStyle().day().month()
          )
        )
        .fontWeight(.bold)
      }

      VStack(alignment: .trailing) {
        Text("Horário")
          .font(.caption)
        Text(event.date.formatted(date: .omitted, time: .shortened))
          .fontWeight(.bold)
      }
    }
    .textCase(.uppercase)
    .fontDesign(.monospaced)
  }

  @ViewBuilder
  private var eventDetails: some View {
    titleSubtitleView(
      title: "Evento",
      subtitle: event.title
    )
    titleSubtitleView(
      title: "Localização",
      subtitle: event.address
    )
    HStack {
      titleSubtitleView(
        title: "Início",
        subtitle: event.date.formatted(date: .omitted, time: .shortened)
      )
      Spacer()
      titleSubtitleView(
        title: "Fim",
        subtitle: event.endDate.formatted(date: .omitted, time: .shortened)
      )
      Spacer()
      titleSubtitleView(
        title: "Data",
        subtitle: event.date.formatted(
          Date.FormatStyle().day().month()
        )
      )
    }
  }

  private func titleSubtitleView(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.caption)

      Text(subtitle)
        .fontWeight(.bold)
    }
    .textCase(.uppercase)
    .fontDesign(.monospaced)
  }
}

#Preview {
  Ticket(event: .mock)
    .padding()
}
