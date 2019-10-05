//
//  VideoModel.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation

struct VideoModel: Codable, Identifiable {
    
    enum VideoError: Error {
        case missingYouTubeUrl, missingTalkId
    }
    
    let id: Int
    private let talkId: Int
    let youTubeUrl: URL
    
    var talk: TalkModel? {
        return Cache.default.talk(with: talkId)
    }
    
}

extension VideoModel {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case talkId = "talk"
        case youTubeUrl = "youtube_url"
    }
}
