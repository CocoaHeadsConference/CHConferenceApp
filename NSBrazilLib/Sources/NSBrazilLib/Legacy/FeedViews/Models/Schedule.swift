
import Foundation

struct ScheduleModel: Codable {
    let date: String
    let talks: [TalkModel]
}

