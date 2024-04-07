//
//  DateFeedView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct DateFeedView: View, FeedViewProtocol {

    init?(feedItem: FeedItem) {
        guard let item = feedItem as? DateFeedItem else { return nil }
        self.feedItem = item
    }

    let feedItem: DateFeedItem

    var body: some View {
        CardView {
            HStack(spacing: 56) {
              ForEach(feedItem.dates) {
                dateDayView(from: $0)
              }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 88)
        }
    }

    private func dateDayView(from date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        let dateText = formatter.string(from: date).uppercased()
        formatter.dateFormat = "EEEE - h:mm"
        let dayHourText = formatter.string(from: date)

        return DateDayView(dateText: dateText, dayHourText: dayHourText)
    }
}

#Preview {
  DateFeedView(feedItem: DateFeedItem(dates: [
      Date(),
      Date()
  ]))

}
