//
//  TalksDashboardView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

@IBDesignable
class TalksDashboardView: CollectionStackView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Theme.shared.mainColor
        self.container.lineSpace = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var state: TalkDashboardViewState = TalkDashboardViewState(talks:[], filter: nil) {
        didSet {
            self.container.state = composeTalkDashboardView(with: state, didSelectCallback: didSelectTalkCallback)
        }
    }
    
    var didSelectTalkCallback: ((TalkModel)-> Void)?
    
    func changeTalkDisplayType(segmentedControl: UISegmentedControl) {
        self.state.filter = TalkModel.TalkType(intValue: segmentedControl.selectedSegmentIndex)
    }
    
}

func composeTalkDashboardView(with state: TalkDashboardViewState, didSelectCallback:((TalkModel)-> Void)?)-> [ComposingUnit] {
    var units: [ComposingUnit] = []
    var groupedTalks = groupByDate(talks: state.filteredTalks)
    groupedTalks.keys.sorted().forEach { (date) in
//        units.add(manyIfLet:groupedTalks[date]) { talks in
//            var dateUnits: [ComposingUnit] = [TalkDashboardUnits.TimeUnit(with: date, hideUpperLine: units.count == 0)]
//            dateUnits.add(manyIfLet: talks) { talks in
//                let sortedTalks = talks.sorted(by: { (first, second) in
//                    let compare = first.date.compare(second.date)
//                    return compare == ComparisonResult.orderedAscending
//                })
//                return sortedTalks.map { talk in
//                    return TalkDashboardUnits.EntryUnit(for: talk, filtered: false, callback: didSelectCallback)
//                }
//            }
//            return dateUnits
//        }
    }
    return units
}

func groupByDate(talks: [TalkModel])-> [Date:[TalkModel]] {
    let grouped: [Date:[TalkModel]] = talks.reduce([:]) { groupedValues, talk in
        var newGroupedValues = groupedValues
        let groupHour = talk.date.startOfDay
        var newTimeFrame: [TalkModel] = []
        if let talksInTimeFrame = groupedValues[groupHour] {
            newTimeFrame = talksInTimeFrame
        }
        newTimeFrame.append(talk)
        newGroupedValues[groupHour] = newTimeFrame
        return newGroupedValues
    }
    return grouped
}
