//
//  DownloadCallToAction.swift
//  NSClip
//
//  Created by Mauricio Cardozo on 1/18/21.
//  Copyright © 2021 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct DownloadCallToAction: View {

  @Environment(\.openURL) var urlOpener
  @Environment(\.horizontalSizeClass) var sizeClass

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Baixe o app!")
          .font(Font.title.bold())
        Spacer()
        Image(systemName: "link.circle")
      }

      Text("Além do cronograma, o app também tem notícias da comunidade :)")
        .font(.caption)
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 25.0, style: .continuous)
        .fill(Color(uiColor: UIColor(resource: .ctaBackground)))
        .shadow(radius: 10)
    )
    .padding(.horizontal, 10)
    .padding(.top, sizeClass == .regular ? 10 : 0)
    .onTapGesture(perform: openAppstorePage)
    .frame(maxWidth: 500)
  }

  private func openAppstorePage() {
    let appstoreURL = URL(string: "https://apps.apple.com/us/app/nsbrazil-2019/id1180455342")!
    urlOpener.callAsFunction(appstoreURL)
  }
}

struct DownloadCallToAction_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      DownloadCallToAction().padding(.bottom)
      DownloadCallToAction()
        .environment(\.colorScheme, .dark)
    }
  }
}
