import Foundation
import SwiftUI

public struct ScheduleListViewModel {

    @ObservedObject var store = NSBrazilStore()

    public init() { }
    
    public var talksFirstDay: [TalkModel] {
        let talksFirstDayArray = store.confMock.schedule[0].talks
        return talksFirstDayArray
    }
    
    public var talksSecondDay: [TalkModel] {
        let talksSecondDayArray = store.confMock.schedule[1].talks
        return talksSecondDayArray
    }

}
