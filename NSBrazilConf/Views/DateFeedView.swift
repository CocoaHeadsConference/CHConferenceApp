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
        HStack(spacing: 56) {
            ForEach(0..<feedItem.dates.count) { index in
                self.dateDayView(from: self.feedItem.dates[index])
            }
        }
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(Color.white)
        .cornerRadius(4)
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .shadow(radius: 10)
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

