//
//  TalkModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct TalkModel: Codable {

    let id: Int
    let speakerId: Int
    let roomId: Int
    let date: Date
    let title: String
    let summary: String
    let fullDescription: String
    let type: TalkType
    let duration: Int
}

extension TalkModel {
    enum CodingKeys: String, CodingKey {
            case id = "id"
            case speakerId = "speaker"
            case roomId = "room"
            case date = "date"
            case title = "title"
            case summary = "summary"
            case fullDescription = "description"
            case type = "type"
            case duration = "duration"
    }
}

enum TalkType: String, Codable {
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

        var hasImage: Bool {
            switch self {
            case .talk, .workshop, .opening, .closing: return true
            case .breaktime, .setup: return false
            }
        }
    
}




extension TalkType {
    
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .talk
        case 1:
            self = .workshop
        case 2:
            self = .opening
        case 3:
            self = .closing
        case 4:
            self = .breaktime
        case 5:
            self = .setup
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .talk:
            try container.encode(0, forKey: .rawValue)
        case .workshop:
            try container.encode(1, forKey: .rawValue)
        case .opening:
            try container.encode(2, forKey: .rawValue)
        case .closing:
            try container.encode(2, forKey: .rawValue)
        case .breaktime:
            try container.encode(2, forKey: .rawValue)
        case .setup:
            try container.encode(2, forKey: .rawValue)
        }
    }
    
}
