import Foundation
import SwiftUI
import MapKit
import Combine

public class FeedViewModel: ObservableObject {

    @ObservedObject var store = NSBrazilStore()
    private var cacheCancellable: AnyCancellable? = nil
    private var storeCancellable: AnyCancellable? = nil

    public init() {
        fetchInfo()
    }

    func fetchInfo() {
        self.cacheCancellable = self.perform(publisher: self.store.fetchCache()) { [weak self] in
            guard let self = self else { return }
            self.storeCancellable = self.perform(publisher: self.store.fetchInfo())
        }
    }
    
    @discardableResult
    private func perform(publisher: AnyPublisher<HomeFeed, FetchError>, completion: (()->Void)? = nil) -> AnyCancellable {
        if homeFeed.isEmpty {
            self.isLoading = true
        }
        return publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { received in
                switch received {
                case .finished:
                    print("sim")
                case .failure(_):
                    print("nao")
                    self.isEmpty = true
                }
                completion?()
            }, receiveValue: { value in
                self.isLoading = false
                self.homeFeed = value.feed.feedItems
                self.scheduleFeed = value.schedule.feedItems
                completion?()
            })
    }

    @Published var homeFeed: [FeedItem] = []
    @Published var scheduleFeed: [FeedItem] = []
    @Published var isEmpty: Bool = false
    @Published var isLoading: Bool = false
}
