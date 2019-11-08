
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

public final class NSBrazilStore: ObservableObject, Store {
    
    private var cancellable: AnyCancellable?
    
    let cache: Cache = Cache()
    public let session: URLSession = URLSession.shared
    let jsonURL: URL = URL(string: "https://nsbrazil.com/app/2019.json")!

    public var objectWillChange = ObservableObjectPublisher()
    
    public init() {
        self.fetchInfo()
    }

    @Published var data: HomeFeed?
    @Published var isLoading: Bool = true

    public func fetchInfo() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        self.cancellable = session.dataTaskPublisher(for: jsonURL)
            .map { $0.data }
            .decode(type: HomeFeed.self, decoder: decoder)
            .mapError { error -> FetchError in
                self.data = nil
                self.isLoading = false
                self.objectWillChange.send()
                switch error {
                    case is DecodingError: return FetchError.parse(error.localizedDescription)
                    default: return FetchError.unknown(error)
                }
            }
            .sink(receiveCompletion: { (completion) in
                print(".sink() received the completion: ", String(describing: completion))
            }, receiveValue: { infos in
                self.objectWillChange.send()
                self.data = infos
                self.isLoading = false
            })
    }

}


