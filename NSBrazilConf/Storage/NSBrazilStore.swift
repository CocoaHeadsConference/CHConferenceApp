
import SwiftUI
import Combine

public enum FetchError: Error {
    case parse(String)
    case unknown(Error)
    case invalidCache

    var localizedDescription: String {
        switch self {
        case .parse(let key):
            return String(format: NSLocalizedString("Unable to parse key %@ from json", comment: "Unable to parse fetch activity error"), key)
        case .unknown(let error):
            return String(format: NSLocalizedString("Unable to find info with identifier %@", comment: "info not found error"), error.localizedDescription)
        case .invalidCache:
            return String(format: NSLocalizedString("Unable to load device cache", comment: "info not found error"))
        }
    }
}

public final class NSBrazilStore: ObservableObject {
    
    private var cancellable: AnyCancellable?
    
    let cache: Cache = Cache()
    public let session: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
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

    func decode(_ data: Data) -> AnyPublisher<NSBrazil.HomeFeed, FetchError> {

        return Just(data)
            .decode(type: HomeFeed.self, decoder: self.contentDecoder)
            .mapError { error in
                switch error {
                case is DecodingError: return FetchError.parse(error.localizedDescription)
                default: return FetchError.unknown(error)
                }
            }.map {
                self.cache.saveCache(data)
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    public func fetchCache() -> AnyPublisher<HomeFeed, FetchError> {
        
        return Just(self.cache.loadCache() ?? Data())
            .decode(type: HomeFeed.self, decoder: self.contentDecoder)
            .mapError { _ in
                return FetchError.invalidCache
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


