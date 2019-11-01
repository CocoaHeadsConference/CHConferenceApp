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

    var feedItem: DateFeedItem

    var body: some View {
        CardView {
            HStack(spacing: 56) {
                ForEach(0..<self.feedItem.dates.count) { index in
                    self.dateDayView(from: self.feedItem.dates[index])
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 88)
        }
    }

    private func dateDayView(from date: Date) -> AnyView {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        let dateText = formatter.string(from: date).uppercased()
        formatter.dateFormat = "EEEE - h:mm"
        let dayHourText = formatter.string(from: date)

        return AnyView(DateDayView(dateText: dateText, dayHourText: dayHourText))
    }
}

struct DateFeedView_Previews: PreviewProvider {
    static var previews: some View {
        DateFeedView(feedItem: DateFeedItem(dates: [
            Date(),
            Date()
        ]))
    }
}

