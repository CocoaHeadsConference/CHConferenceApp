//
//  ScheduleListView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct ScheduleListView: View {

    let viewModel: FeedViewModel

    var body: some View {
        VStack {
            ForEach(0..<viewModel.scheduleFeed.count) { feedIndex in
                FeedBuilder.view(for: self.viewModel.scheduleFeed[feedIndex])
            }
        }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView(viewModel: FeedViewModel())
    }
}
