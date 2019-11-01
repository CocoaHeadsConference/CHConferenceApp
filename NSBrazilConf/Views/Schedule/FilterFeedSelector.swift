//
//  FilterFeedSelector.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/31/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterFeedSelector: View {

    var initialIndex: Int
    var label: String = "placeholder"
    @Binding var selectedFeed: Int

    var body: some View {
        if initialIndex == selectedFeed {
            return AnyView (
                Text(label.uppercased())
                    .font(.headline)
                    .frame(minWidth: 100, alignment: .center)
                    .padding()
                    .background(Color("buttonBackground"))
                    .cornerRadius(8)
            )
        } else {
            return AnyView(
                Button(action: {
                    self.selectedFeed = self.initialIndex
                }) {
                    Text(label.uppercased())
                        .font(.headline)
                        .foregroundColor(Color.black)
                        .frame(minWidth: 100, alignment: .center)
                        .padding()
                        .background(Color("buttonBackground"))
                        .cornerRadius(8)

                }
            )
        }
    }
}

struct FilterFeedSelector_Previews: PreviewProvider {

    @State static var feed: Int = 0

    static var previews: some View {
        HStack(spacing: 20) {
            FilterFeedSelector(initialIndex: 0, label: "Sabado", selectedFeed: $feed)
            FilterFeedSelector(initialIndex: 1, label: "Domingo", selectedFeed: $feed)
        }

    }
}
