import Combine
import SwiftUI

public enum FetchError: Error {
  case parse(String)
  case unknown(Error)
  case invalidCache(Error)

  var localizedDescription: String {
    switch self {
    case .parse(let key):
      return String(
        format: NSLocalizedString(
          "Unable to parse key %@ from json", comment: "Unable to parse fetch activity error"), key)
    case .unknown(let error):
      return String(
        format: NSLocalizedString(
          "Unable to find info with identifier %@", comment: "info not found error"),
        error.localizedDescription)
    case .invalidCache(let error):
      return String(
        format: NSLocalizedString(
          "Unable to load device cache %@", comment: "info not found error"),
        error.localizedDescription)
    }
  }
}

public final class NSBrazilStore: ObservableObject {

  private var cancellable: AnyCancellable?

  let cache: Cache = Cache()
  public let session: URLSession = URLSession.shared
  let jsonURL: URL = URL(string: "https://nsbrazil.com/app/2019.json")!

  private lazy var contentDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  public var objectWillChange = ObservableObjectPublisher()

  public init() {}

  @Published var data: HomeFeed?
  @Published var isLoading: Bool = true

  func decode(_ data: Data) -> AnyPublisher<HomeFeed, FetchError> {

    return Just(data)
      .decode(type: HomeFeed.self, decoder: self.contentDecoder)
      .handleEvents(receiveCompletion: { (completion) in
        if case .finished = completion {
          self.cache.saveCache(data)
        }
      }).mapError { error in
        switch error {
        case is DecodingError: return FetchError.parse(error.localizedDescription)
        default: return FetchError.unknown(error)
        }
      }.eraseToAnyPublisher()
  }

  public func fetchCache() -> AnyPublisher<HomeFeed, FetchError> {

    return Just(self.cache.loadCache() ?? Data())
      .decode(type: HomeFeed.self, decoder: self.contentDecoder)
      .mapError { error in
        return FetchError.invalidCache(error)
      }
      .eraseToAnyPublisher()
  }

  public func fetchInfo() -> AnyPublisher<HomeFeed, FetchError> {
    return session.dataTaskPublisher(for: jsonURL)
      .map { $0.data }
      .mapError({ error -> FetchError in
        return FetchError.unknown(error)
      })
      .flatMap(maxPublishers: .max(1)) { pair in
        self.decode(pair)
      }.eraseToAnyPublisher()
  }
}
