
import SwiftUI
import Combine


public enum FetchError: Error {
    case parse(String)
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .parse(let key):
            return String(format: NSLocalizedString("Unable to parse key %@ from activity", comment: "Unable to parse user activity error"), key)
        case .unknown(let error):
            return String(format: NSLocalizedString("Unable to find info with identifier %@", comment: "info not found error"), error.localizedDescription)
        }
    }
}

public final class NSBrazilStore: ObservableObject, Store {
    
    private var cancellable: AnyCancellable?
    
    let cache: Cache = Cache()
    let session: URLSession = URLSession.shared
    let jsonURL: URL = URL(string: "http://cocoaheadsconference.com.br/app/2018.json")!
    
    public init() {
        //self.fetchInfo()
    }
    
    @Published var conf: NSBrazilData?
        
    @Published var confMock: NSBrazilData = {
        guard let url = Bundle.nsbrazilConf.url(forResource: "MockData", withExtension: "json") else {
            fatalError("CocoaheadsConf MockData.json from NSBrazilConf resources")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try JSONDecoder().decode(NSBrazilData.self, from: data)
        } catch {
            fatalError("Failed to load demo content: \(String(describing: error))")
        }
    }()

    @Published var newData: HomeFeed = {
        guard let url = Bundle.nsbrazilConf.url(forResource: "2019", withExtension: "json") else { fatalError("deu ruim") }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(HomeFeed.self, from: data)
        } catch {
            fatalError("deu ruim mesmo")
        }
    }()
    

    public func fetchInfo() {
        self.cancellable = session.dataTaskPublisher(for: jsonURL)
            .map { $0.data }
            .decode(type: NSBrazilData.self, decoder: JSONDecoder())
            .mapError { error -> FetchError in
                switch error {
                    case is DecodingError: return FetchError.parse(error.localizedDescription)
                    default: return FetchError.unknown(error)
                }
            }
            .sink(receiveCompletion: { (completion) in
                print(".sink() received the completion: ", String(describing: completion))
            }, receiveValue: { infos in
                self.conf = infos
            })
    
    }
}


