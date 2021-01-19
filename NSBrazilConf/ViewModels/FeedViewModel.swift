import Foundation
import SwiftUI
import MapKit
import Combine

public class FeedViewModel: ObservableObject {

    enum LoadState {
        case loading
        case loaded
        case failed
    }

    @ObservedObject var store = NSBrazilStore()
    private var cancellable: AnyCancellable? = nil

    public init() {
        fetchInfo()
    }

    func fetchInfo() {
        self.isLoading = .loading
        
        let cachePublisher = self.store.fetchCache()
        let networkPublisher = self.store.fetchInfo()
        
        self.cancellable?.cancel()
        self.cancellable = networkPublisher.catch({ _ in cachePublisher})
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { received in
                switch received {
                case .finished:
                    self.isLoading = .loaded
                case .failure(_):
                    self.isLoading = .failed
                }
            }, receiveValue: { value in
                self.homeFeed = value.feed.feedItems
                self.scheduleFeed = value.schedule.feedItems
            })
    }

    @Published var homeFeed: [FeedItem] = []
    @Published var scheduleFeed: [FeedItem] = []
    @Published var isLoading: LoadState = .loading
}
