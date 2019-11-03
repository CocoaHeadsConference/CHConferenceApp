import Foundation
import SwiftUI
import MapKit

public struct FeedViewModel {

    @ObservedObject var store = NSBrazilStore()

    public init() { }

    var homeFeed: [FeedItem] {
        return store.data?.feed.feedItems ?? []
    }

    var scheduleFeed: [FeedItem] {
        return store.data?.schedule.feedItems ?? []
    }

    var isEmpty: Bool {
        return homeFeed.isEmpty && scheduleFeed.isEmpty
    }
}
