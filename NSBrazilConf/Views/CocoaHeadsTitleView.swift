//
//  CocoaHeadsTitleView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct CocoaHeadsTitleView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("O Evento nacional do\nCocoaHeads Brasil")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 24)

    }
}

struct CocoaHeadsTitleView_Previews: PreviewProvider {
    static var previews: some View {
        CocoaHeadsTitleView()
    }
}
