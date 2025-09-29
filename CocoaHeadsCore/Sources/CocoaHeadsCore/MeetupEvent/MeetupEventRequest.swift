public struct MeetupEventRequest: Codable {
  public init(url: String) {
    self.url = url
  }

  public let url: String
}
