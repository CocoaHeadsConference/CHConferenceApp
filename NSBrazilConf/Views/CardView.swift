//
//  CardView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 11/1/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI
import MapKit

struct CardView<Content>: View where Content: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            content()
        }
        .background(Color.white)
        .cornerRadius(8)
        .padding()
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardView {
                MapView(location: CLLocationCoordinate2D(), annotationTitle: "", span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
            CardView {
                Text("Hmm").padding()
            }
        }.previewDevice(.iPhone11)
    }
}
