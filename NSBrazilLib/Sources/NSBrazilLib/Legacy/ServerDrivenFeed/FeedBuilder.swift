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

public struct FeedBuilder {
    static let typeDictionary: [FeedItemType: FeedItem.Type] = [
        .text: TextFeedItem.self,
        .subtitle: SubtitleFeedItem.self,
        .date: DateFeedItem.self,
        .map: MapFeedItem.self,
        .videos: VideoFeedItem.self,
        .sponsors: SponsorFeedItem.self,
        .talk: TalkFeedItem.self,
        .filterFeed: FilterFeedItem.self,
    ]

  @ViewBuilder
  public static func view(for item: FeedItem) -> some View {
        switch item.type {
        case .text:
            TitleView(feedItem: item)
        case .subtitle:
            TitleHeaderView(feedItem: item)
        case .date:
             DateFeedView(feedItem: item)
        case .map:
             MapFeedView(feedItem: item)
        case .videos:
             VideoSectionView(feedItem: item)
        case .sponsors:
             SponsorsViewSection(feedItem: item)
        case .talk:
             TalkView(feedItem: item)
        case .unknown:
             EmptyView()
        case .filterFeed:
             FilterFeedView(feedItem: item)
        }
    }
}
