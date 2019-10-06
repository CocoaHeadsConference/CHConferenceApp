
import UIKit

public struct TalkModel: Codable, Identifiable {

    public let id: Int
    public let title: String
    public let speaker: String
    public let speakerImage: String
    public let speakerTitle: String
    public let twitterHandle: String
    public let linkedinHandler: String
    public let githubHandler: String
    public let room: String
    public let date: String
    public let bio: String
    public let summary: String
    public let type: TalkType
    public let duration: Int
    public let idioma: String
}

public enum TalkType: String, Codable {
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
    
    public init(from decoder: Decoder) throws {
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

