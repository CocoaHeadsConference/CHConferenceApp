//
//  FeedBuilder.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

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
}
