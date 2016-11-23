//
//  VideoModel.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation
import Marshal

struct VideoModel: Unmarshaling {
    
    enum VideoError: Error {
        case missingYouTubeUrl, missingTalkId
    }
    
    let id: Int
    private let talkId: Int
    let youTubeUrl: URL
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        talkId = try object.value(for: "talk")
        youTubeUrl = try object.value(for: "youtube_url")
    }
    
    var talk: TalkModel? {
        return Cache.default.talk(with: talkId)
    }
    
}
