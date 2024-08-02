//
//  PastEditionCardView.swift
//  NSBrazilConf
//
//  Created by Douglas Alexandre Barros Taquary on 23/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct VideoCardView: View {
    let video: Video
    @State var showContent = false
    
    var body: some View {
      #if os(watchOS)
      WatchFriendlyLink(url: video.link) {
        content
      }
      #else
      Button {
        showContent.toggle()
      } label: {
        content
      }
      .buttonStyle(.plain)
      .sheet(isPresented: $showContent, content: {
          VideoView(videoUrl: self.video.link)
        #if os(visionOS)
          .frame(minWidth: 500, minHeight: 500)
        #endif
      })
      #endif
    }

  @MainActor @ViewBuilder
  var content: some View {
    CardView {
        VStack(alignment: .leading, spacing: 10) {
            Text(self.video.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .lineLimit(4)
                .shadow(radius: 1)
            Text(self.video.speaker)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(.horizontal, 10)
                .lineLimit(1)
                .shadow(radius: 1)
            Spacer()
            HStack {
                Spacer()
                Image("ic_play")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)
                .padding()
                Spacer()
            }
            Spacer()
            .fixedSize()
            .frame(width: nil, height: 30)

        }
        .background(
            ImageViewContainer(imageURL: self.video.background, hasPadding: false, contentMode: .fill)
        )
        .background(self.video.backgroundColor)
        .frame(width: 246, height: 360)
    }
  }
}

#Preview {
  VideoCardView(video: 
    Video(title: "The roots",
          speaker: "Felipe Lefèvre Marino",
          background: URL(string: "https://google.com")!,
          link: URL(string: "https://www.cocoaheads.com.br/videos/detalhes/20")!)
  )
}
