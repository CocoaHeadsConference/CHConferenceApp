//
//  FeedBuilder.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

protocol FeedViewProtocol {
    init?(feedItem: FeedItem)
}

struct FeedBuilder {
    static let typeDictionary: [FeedItemType: FeedItem.Type] = [
        .text: TextFeedItem.self,
        .date: DateFeedItem.self,
        .map: MapFeedItem.self,
        .videos: VideoFeedItem.self,
        .sponsors: SponsorFeedItem.self,
        .talk: TalkFeedItem.self,
        .filterFeed: FilterFeedItem.self,
    ]

    static func view(for item: FeedItem) -> AnyView {
        switch item.type {
        case .text:
            return AnyView(EmptyView())
        case .date:
            return AnyView(DateFeedView(feedItem: item))
        case .map:
            return AnyView(MapFeedView(feedItem: item))
        case .videos:
            return AnyView(EmptyView())
        case .sponsors:
            return AnyView(EmptyView())
        case .talk:
            return AnyView(EmptyView())
        case .unknown:
            return AnyView(EmptyView())
        case .filterFeed:
            return AnyView(EmptyView())
        }
    }
}
