//
//  ScheduleListView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI


struct ScheduleListView: View {

    let scheduleViewModel: ScheduleListViewModel
    
    @State var showSetting = false
    
    var body: some View {
            VStack {
                ForEach(0..<scheduleViewModel.feed.count) { feedIndex in
                    FeedBuilder.view(for: self.scheduleViewModel.feed[feedIndex])
                }
            }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView(scheduleViewModel: ScheduleListViewModel())
    }
}
