//
//  ActivityIndicatorView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 11/8/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    typealias UIViewType = UIActivityIndicatorView

    let indicator = UIActivityIndicatorView()

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> ActivityIndicatorView.UIViewType {
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
    }

}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView()
    }
}
