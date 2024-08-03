
import Foundation

struct NSBrazilData: Codable {
    let feed: [FeedModel]
    let sponsors: [SponsorModel]
    let schedule: [ScheduleModel]
    let videos: [VideoModel]
}

extension NSBrazilData {
    enum CodingKeys: String, CodingKey {
        case feed
        case sponsors
        case schedule
        case videos
    }
}

