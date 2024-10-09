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
      ForEach(viewModel.scheduleFeed) { item in
        FeedBuilder.view(for: item)
      }
    }
  }
}

#Preview {
  ScheduleListView(viewModel: FeedViewModel())
}
