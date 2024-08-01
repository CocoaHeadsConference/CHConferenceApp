//
//  RetryView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 11/2/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

// TODO: This can be replaced by ContentUnavailableView

struct RetryView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(decorative: "sad").renderingMode(.template).accentColor(Color(UIColor.label))
            Text("Algo deu errado").accentColor(Color(UIColor.label))
        }
    }
}

#Preview {
  RetryView()
}
