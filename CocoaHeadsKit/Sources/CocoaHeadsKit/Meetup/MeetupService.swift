//
//  MeetupService.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import CocoaHeadsCore
import CoreLocation
import SwiftSoup

struct MeetupService {
  func event(from urlString: String) async throws -> MeetupEvent {
    guard
      let url = URL(string: urlString),
      case (let data, _) = try await URLSession.shared.data(from: url),
      let html = String(data: data, encoding: .utf8)
    else {
      throw Error.urlError
    }

    guard !url.absoluteString.contains("Entrar") else {
      throw Error.pastEventError
    }

    let document = try SwiftSoup.parse(html)

    return MeetupEvent(
      title: try parseTitle(from: document),
      address: try parseAddress(from: document),
      location: try parseLocation(from: document),
      description: try parseDescription(from: document),
      date: try parseDate(from: document),
      url: url,
      image: try parseImage(from: document)
    )
  }

  func parseTitle(from document: Document) throws -> String {
    let title = try document.title()
    return "\(title.split(separator: ",").first ?? "")"
  }

  func parseAddress(from document: Document) throws -> String {
    guard
      let eventLocation = try document.select("[data-event-label='event-location']").first()?.text(),
      let addressElement = try document.select("[data-testid='location-info']").first(),
      case let address = try addressElement.text()
    else {
      throw Error.addressError
    }

    return eventLocation + "\n" + address
  }

  func parseLocation(from document: Document) throws -> MeetupEvent.Location {
    let latlngString = try document.select("[data-event-label='event-map']").first()?.attr("href") ?? ""
    let latLng = extractCoordinates(from: latlngString)
    guard let (lat, lng) = latLng else {
      throw Error.coordinateError
    }

    return MeetupEvent.Location(
      latitude: lat,
      longitude: lng
    )
  }

  private func extractCoordinates(from urlString: String) -> (latitude: Double, longitude: Double)? {
    // Example string: https://www.google.com/maps/search/?api=1&query=37.32431%2C%20-122.011566
    guard
      let url = URL(string: urlString),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let queryItem = components.queryItems?.first(where: { $0.name == "query" }),
      let coordinatesString = queryItem.value
    else {
      return nil
    }

    let coordinates = coordinatesString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

    if coordinates.count == 2,
      let latitude = Double(coordinates[0]),
      let longitude = Double(coordinates[1])
    {
      return (latitude, longitude)
    }

    return nil
  }

  func parseDescription(from document: Document) throws -> String {
    try document.select("div#event-details").first()?
      .text()
      .removingFirstOccurrence(of: "detalhes")
      .removingFirstOccurrence(of: "details") ?? ""
  }

  func parseDate(from document: Document) throws -> Date {
    guard let dateTime = try document.select("time").first()?.attr("datetime") else {
      throw Error.dateError
    }
    return try Date.ISO8601FormatStyle().parse(dateTime)
  }

  func parseImage(from document: Document) throws -> URL {
    guard
      let imageString = try document.select("[data-testid='event-description-image']").select("img").first()?.attr(
        "src"),
      let url = URL(string: imageString)
    else {
      throw Error.imageError
    }
    return url
  }

  enum Error: Swift.Error, LocalizedError {
    case addressError
    case coordinateError
    case dateError
    case imageError
    case pastEventError
    case urlError

    var localizedDescription: String {
      switch self {
      case .addressError:
        "Erro ao buscar o endereço"
      case .coordinateError:
        "Erro no parse das coordenadas"
      case .dateError:
        "Não consegui encontrar ou fazer decode da data"
      case .imageError:
        "Não encontrei a URL da imagem"
      case .pastEventError:
        "Em caso de eventos passados, o Meetup redireciona para uma página de Login, sendo assim, não é possível extrair os dados"
      case .urlError:
        "Erro na URL"
      }
    }
  }
}

extension String {
  fileprivate func removingFirstOccurrence(of word: String) -> String {
    guard let range = range(of: "\\b\(word)\\b", options: [.regularExpression, .caseInsensitive]) else {
      return self
    }
    return replacingCharacters(in: range, with: "")
  }
}
