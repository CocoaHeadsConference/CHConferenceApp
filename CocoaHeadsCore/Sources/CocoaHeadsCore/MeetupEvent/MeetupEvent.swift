//
//  MeetupEvent.swift
//
//
//  Created by Mauricio Cardozo on 9/28/25.
//

import Foundation

public struct MeetupEvent: Codable, Equatable, Sendable {
  public init(
    title: String,
    address: String,
    location: MeetupEvent.Location,
    description: String,
    date: Date,
    url: URL,
    image: URL? = nil,
    talks: [Talk] = []
  ) {
    self.title = title
    self.address = address
    self.location = location
    self.description = description
    self.date = date
    self.url = url
    self.image = image
    self.talks = talks
  }

  public let title: String
  public let address: String
  public let location: Location
  public let description: String
  public let date: Date
  public let url: URL
  public let image: URL?
  public let talks: [Talk]

  public struct Location: Codable, Equatable, Sendable {
    public init(latitude: Double, longitude: Double) {
      self.latitude = latitude
      self.longitude = longitude
    }

    public let latitude: Double
    public let longitude: Double
  }

  public struct Talk: Codable, Equatable, Sendable {
    public init(speaker: String, title: String) {
      self.speaker = speaker
      self.title = title
    }

    public let speaker: String
    public let title: String
  }
}
