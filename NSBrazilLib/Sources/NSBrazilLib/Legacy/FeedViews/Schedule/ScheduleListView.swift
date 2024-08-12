//
//  ScheduleListView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

public struct ScheduleListView: View {
  public init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }

  let viewModel: FeedViewModel

  public var body: some View {
    VStack {
      ForEach(0..<viewModel.scheduleFeed.count) { feedIndex in
        FeedBuilder.view(for: self.viewModel.scheduleFeed[feedIndex])
      }
    }
  }
}

#Preview {
  ScheduleListView(viewModel: FeedViewModel())
}
