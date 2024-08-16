//
//  FeedItemType.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

public enum FeedItemType: String, Codable {
  case text, subtitle, date, map, videos, sponsors, talk, unknown, filterFeed
}
