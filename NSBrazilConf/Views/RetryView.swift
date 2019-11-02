//
//  RetryView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 11/2/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct RetryView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(decorative: "sad").renderingMode(.template).accentColor(Color(UIColor.label))
            Text("Algo deu errado").accentColor(Color(UIColor.label))
        }
    }
}

struct RetryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RetryView().previewDevice(.iPhone11)
            RetryView().previewDevice(.iPhone11).environment(\.colorScheme, .dark)
        }

    }
}
