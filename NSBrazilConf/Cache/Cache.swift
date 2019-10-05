//
//  Cache.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class Cache: NSObject {

    static let `default`: Cache = Cache()
    
    var speakers: [Int:SpeakerModel] = [:]
    var rooms: [Int:RoomModel] = [:]
    var talks: [Int:TalkModel] = [:]
    var sponsors: [SponsorModel] = []
    var videos: [Int:VideoModel] = [:]
    
    var event: FeedModel?
    
    func talk(with id: Int)-> TalkModel? {
        return talks[id]
    }
    
    func talks(for speaker: SpeakerModel)-> [TalkModel]? {
        return []
    }
    
    func speaker(with id: Int)-> SpeakerModel? {
        return speakers[id]
    }
    
    func room(with id: Int)-> RoomModel? {
        return rooms[id]
    }
    
    func video(with id: Int) -> VideoModel? {
        return videos[id]
    }
    
    func video(for talk: Int) -> VideoModel? {
        return videos.compactMap({ $0.1 }).filter({ $0.talk?.id == talk }).first
    }
    
    func `import`(store: NSBrazilData) throws {
//        let allSpeakers: [SpeakerModel] = try json.value(for: "speakers")
//        allSpeakers.forEach { speakers[$0.id] = $0 }
//        let allRooms: [RoomModel] = try json.value(for: "rooms")
//        allRooms.forEach { rooms[$0.id] = $0 }
//        let allTalks: [TalkModel] = try json.value(for: "talks")
//        allTalks.forEach { talks[$0.id] = $0 }
//        sponsors = try json.value(for: "sponsors")
//        let allVideos: [VideoModel] = try json.value(for: "videos")
//        allVideos.forEach({ videos[$0.id] = $0 })
//        event = try json.value(for: "event")
//        let theme: Theme = try json.value(for: "theme")
//        Theme.shared.apply(theme: theme)
    }
    
}
