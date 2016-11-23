//
//  TalkModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

struct TalkModel: Unmarshaling {

    enum TalkError: Error {
        case missingSpeaker, missingRoom
    }
    
    enum TalkType: String {
        case talk, workshop, opening, closing, breaktime, setup
        
        init?(intValue: Int) {
            switch intValue {
            case 1:
                self = .talk
            case 2:
                self = .workshop
            default:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .talk: return "Palestra"
            case .workshop: return "Workshop"
            case .opening: return "Abertura"
            case .closing: return "Encerramento"
            case .breaktime: return "Intervalo"
            case .setup: return "Credenciamento"
            }
        }
        
        var color: UIColor {
            switch self {
            case .talk: return UIColor(hexString: "D84315")
            case .workshop: return UIColor(hexString: "00838F")
            case .opening: return UIColor(hexString: "AD1457")
            case .closing: return UIColor(hexString: "AD1457")
            case .breaktime: return UIColor(hexString: "F9A825")
            case .setup: return UIColor(hexString: "9E9D24")
            }
        }
        
        var excludeFilter: TalkType {
            switch self {
            case .talk:
                return .workshop
            case .workshop:
                return .talk
            default:
                return .setup
            }
        }
        
        var backgroundColor: UIColor {
            return UIColor.black.withAlphaComponent(0.55)
        }
        
        var hasImage: Bool {
            switch self {
            case .talk, .workshop, .opening, .closing: return true
            case .breaktime, .setup: return false
            }
        }
    }
    
    let id: Int
    private let speakerId: Int
    private let roomId: Int
    let date: Date
    let title: String
    let summary: String
    let fullDescription: String
    let type: TalkType
    let duration: Int
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        date = try object.value(for: "date")
        title = try object.value(for: "title")
        summary = try object.value(for: "summary")
        fullDescription = try object.value(for: "description")
        type = try object.value(for: "type")
        speakerId = try object.value(for: "speaker")
        roomId = try object.value(for: "room")
        duration = try object.value(for: "duration")
    }
    
    var speaker: SpeakerModel? {
        return Cache.default.speaker(with: speakerId)
    }
    
    var room: RoomModel? {
        return Cache.default.room(with: roomId)
    }
    
}
