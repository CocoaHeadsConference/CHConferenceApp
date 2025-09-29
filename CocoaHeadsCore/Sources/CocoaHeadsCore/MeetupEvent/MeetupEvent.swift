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
    image: URL? = nil
  ) {
    self.title = title
    self.address = address
    self.location = location
    self.description = description
    self.date = date
    self.url = url
    self.image = image
  }
  
  public let title: String
  public let address: String
  public let location: Location
  public let description: String
  public let date: Date
  public let url: URL
  public let image: URL?
  
  public struct Location: Codable, Equatable, Sendable {
    public init(latitude: Double, longitude: Double) {
      self.latitude = latitude
      self.longitude = longitude
    }

    public let latitude: Double
    public let longitude: Double
  }
}
