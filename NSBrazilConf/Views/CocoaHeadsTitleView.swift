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
            VStack(alignment: .leading) {
                Text("O Evento nacional do\nCocoaHeads Brasil")
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                Text("Auditório Itáu")
                    .foregroundColor(.gray)
            }
        }

    }
}

struct CocoaHeadsTitleView_Previews: PreviewProvider {
    static var previews: some View {
        CocoaHeadsTitleView()
    }
}
