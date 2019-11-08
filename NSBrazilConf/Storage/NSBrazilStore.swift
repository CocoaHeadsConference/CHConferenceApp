
import SwiftUI
import Combine

public enum FetchError: Error {
    case parse(String)
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .parse(let key):
            return String(format: NSLocalizedString("Unable to parse key %@ from json", comment: "Unable to parse fetch activity error"), key)
        case .unknown(let error):
            return String(format: NSLocalizedString("Unable to find info with identifier %@", comment: "info not found error"), error.localizedDescription)
        }
    }
}

public final class NSBrazilStore: ObservableObject {
    
    private var cancellable: AnyCancellable?
    
    let cache: Cache = Cache()
    public let session: URLSession = URLSession.shared
    let jsonURL: URL = URL(string: "https://nsbrazil.com/app/2019.json")!

    public var objectWillChange = ObservableObjectPublisher()
    
    public init() {}

    @Published var data: HomeFeed?
    @Published var isLoading: Bool = true

    func decode(_ data: Data) -> AnyPublisher<NSBrazil.HomeFeed, FetchError> {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601

      return Just(data)
        .decode(type: HomeFeed.self, decoder: decoder)
        .mapError { error in
          switch error {
              case is DecodingError: return FetchError.parse(error.localizedDescription)
              default: return FetchError.unknown(error)
          }
        }
        .eraseToAnyPublisher()
    }

    public func fetchInfo() -> AnyPublisher<HomeFeed, FetchError> {
        return session.dataTaskPublisher(for: jsonURL)
            .map { $0.data }
            .mapError( { error -> FetchError in
                return FetchError.unknown(error)
            })
            .flatMap(maxPublishers: .max(1)) { pair in
                self.decode(pair)
            }.eraseToAnyPublisher()
    }
}


