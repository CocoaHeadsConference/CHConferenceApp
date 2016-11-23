//
//  Cache.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

class Cache: NSObject {

    static let `default`: Cache = Cache()
    
    var speakers: [Int:SpeakerModel] = [:]
    var rooms: [Int:RoomModel] = [:]
    var talks: [Int:TalkModel] = [:]
    var videos: [Int:VideoModel] = [:]
    
    func talk(with id: Int)-> TalkModel? {
        return talks[id]
    }
    
    func talks(for speaker: SpeakerModel)-> [TalkModel]? {
        return talks.filter { (key, talk) in
            return talk.speaker?.id == speaker.id
        }.map { $1 }.sorted { (first, second) in
            return first.date.compare(second.date) == .orderedAscending
        }
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
    
    func `import`(json: [String:Any]) throws {
        let allSpeakers: [SpeakerModel] = try json.value(for: "speakers")
        allSpeakers.forEach { speakers[$0.id] = $0 }
        let allRooms: [RoomModel] = try json.value(for: "rooms")
        allRooms.forEach { rooms[$0.id] = $0 }
        let allTalks: [TalkModel] = try json.value(for: "talks")
        allTalks.forEach { talks[$0.id] = $0 }
        let allVideos: [VideoModel] = try json.value(for: "videos")
        allVideos.forEach({ videos[$0.id] = $0 })
    }
    
}
