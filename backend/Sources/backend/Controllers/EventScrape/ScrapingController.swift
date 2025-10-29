//
//  ScrapingController.swift
//  backend
//
//  Created by Mauricio Cardozo on 9/28/25.
//

import CocoaHeadsCore
import Vapor

struct ScrapingController: RouteCollection {
  let firecrawl: any FirecrawlServiceProtocol

  func boot(routes: any Vapor.RoutesBuilder) throws {
    let meetupRoutes = routes.grouped("scrape")
    meetupRoutes.post(use: self.event)
  }

  @Sendable
  func event(req: Request) async throws -> MeetupEvent {
    let meetup = try req.content.decode(MeetupEventRequest.self)

    guard let url = URL(string: meetup.url) else {
      throw MeetupError.urlError
    }

    let extractedData: ExtractedEventData = try await firecrawl.extract(
      req: req,
      request: createFirecrawlRequest(
        for: url
      )
    )

    guard let eventDate = ISO8601DateFormatter().date(from: extractedData.eventDate) else {
      throw MeetupError.dateError
    }

    let location = MeetupEvent.Location(
      latitude: extractedData.latitude ?? 0.0,
      longitude: extractedData.longitude ?? 0.0
    )

    let fullAddress: String
    if let addressName = extractedData.addressName {
      fullAddress = "\(addressName)\n\(extractedData.address)"
    } else {
      fullAddress = extractedData.address
    }

    let description = extractedData.eventDescription

    let talks =
      extractedData.talks?.map {
        MeetupEvent.Talk(speaker: $0.speakerName, title: $0.talkTitle)
      } ?? []

    let imageURL = extractedData.coverImageURL.flatMap { URL(string: $0) }

    return MeetupEvent(
      title: extractedData.eventTitle,
      address: fullAddress,
      location: location,
      description: description,
      date: eventDate,
      url: url,
      image: imageURL,
      talks: talks
    )
  }

  private func createFirecrawlRequest(for event: URL) -> FirecrawlRequest {
    let schema = FirecrawlSchema(
      type: "object",
      properties: [
        "event_title": SchemaProperty(type: "string"),
        "event_date": SchemaProperty(type: "string", description: "ISO 8601 formatted date"),
        "address": SchemaProperty(type: "string"),
        "address_name": SchemaProperty(type: "string"),
        "latitude": SchemaProperty(type: "number"),
        "longitude": SchemaProperty(type: "number"),
        "event_description": SchemaProperty(type: "string"),
        "cover_image_url": SchemaProperty(type: "string"),
        "talks": SchemaProperty(
          type: "array",
          items: NestedProperty(
            type: "object",
            properties: [
              "talk_title": SchemaProperty(type: "string"),
              "speaker_name": SchemaProperty(type: "string")
            ]
          )
        )
      ],
      required: ["event_title", "event_date", "address", "event_description"]
    )

    return FirecrawlRequest(
      urls: [event.absoluteString],
      schema: schema
    )
  }
}

struct ExtractedEventData: Content {
  let eventTitle: String
  let eventDate: String
  let address: String
  let addressName: String?
  let latitude: Double?
  let longitude: Double?
  let eventDescription: String
  let coverImageURL: String?
  let talks: [Talk]?

  struct Talk: Codable {
    let talkTitle: String
    let speakerName: String

    enum CodingKeys: String, CodingKey {
      case talkTitle = "talk_title"
      case speakerName = "speaker_name"
    }
  }

  enum CodingKeys: String, CodingKey {
    case eventTitle = "event_title"
    case eventDate = "event_date"
    case address
    case addressName = "address_name"
    case latitude
    case longitude
    case eventDescription = "event_description"
    case coverImageURL = "cover_image_url"
    case talks
  }
}

extension MeetupEvent: @retroactive RequestDecodable {}
extension MeetupEvent: @retroactive ResponseEncodable {}
extension MeetupEvent: @retroactive AsyncRequestDecodable {}
extension MeetupEvent: @retroactive AsyncResponseEncodable {}
extension MeetupEvent: @retroactive Content {}

extension MeetupError: @retroactive AbortError {
  public var status: HTTPStatus { .internalServerError }
  public var reason: String { return localizedDescription }
}
