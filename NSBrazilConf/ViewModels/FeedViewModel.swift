import Foundation
import SwiftUI
import MapKit
import Combine

public class FeedViewModel: ObservableObject {

    @ObservedObject var store = NSBrazilStore()
    private var cancellable: AnyCancellable? = nil

    public init() {
        fetchInfo()
    }

    func fetchInfo() {
        isLoading = true
        cancellable = store.fetchInfo()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { received in
                switch received {
                case .finished:
                    print("sim")
                case .failure(_):
                    print("nao")
                    self.isEmpty = true
                }
            }, receiveValue: { value in
                self.isLoading = false
                self.homeFeed = value.feed.feedItems
                self.scheduleFeed = value.feed.feedItems
            })
    }

    @Published var homeFeed: [FeedItem] = []
    @Published var scheduleFeed: [FeedItem] = []
    @Published var isEmpty: Bool = false
    @Published var isLoading: Bool = false
}
