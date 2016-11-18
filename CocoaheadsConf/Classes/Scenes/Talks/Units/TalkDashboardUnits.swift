//
//  TalkDashboardUnits.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct TalkDashboardUnits {

    private init() { }
    
    static let timeDateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static func TimeUnit(with date: Date, hideUpperLine: Bool)-> ComposingUnit {
        return TimeDisplayUnit(date: date, hideUpperLine: hideUpperLine)
    }
    
    static func EntryUnit(for talk: TalkModel, filtered: Bool)-> ComposingUnit {
        return TalkUnit(talk: talk)
    }
    
}
