
import UIKit

struct TalkModel: Codable, Identifiable {

    let id: Int
    let title: String
    let speaker: String
    let speakerImage: String
    let speakerTitle: String
    let twitterHandle: String
    let linkedinHandler: String
    let githubHandler: String
    let room: String
    let date: String
    let bio: String
    let summary: String
    let type: TalkType
    let duration: Int
    let idioma: String
}

enum TalkType: String, Codable {
        case talk, workshop, opening, closing, breaktime, setup

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
    
    enum CodingKeys: String, CodingKey {
       case type = "type"
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        switch rawValue {
        case "talk":
            self = .talk
        case "workshop":
            self = .workshop
        case "opening":
            self = .opening
        case "closing":
            self = .closing
        case "breaktime":
            self = .breaktime
        case "setup":
            self = .setup
        default:
            throw CodingError.unknownValue
        }
    }

}

