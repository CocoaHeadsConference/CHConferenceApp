//
//  TalkDashboardViewState.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct TalkDashboardViewState {

    var talks: [TalkModel]
    
    var filter: TalkModel.TalkType?
    
    var filteredTalks: [TalkModel] {
        guard let filter = filter else {
            return talks
        }
        return talks.filter({ (model) -> Bool in
            return model.type != filter.excludeFilter
        })
    }
    
}
