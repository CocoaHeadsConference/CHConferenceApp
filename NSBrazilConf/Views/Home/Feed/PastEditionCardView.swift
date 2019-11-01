//
//  PastEditionCardView.swift
//  NSBrazilConf
//
//  Created by Douglas Alexandre Barros Taquary on 23/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct PastEditionCardView: View {
    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(video.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .lineLimit(4)
                .shadow(radius: 1)
            Text(video.speaker)
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
            ImageViewContainer(imageURL: video.background, hasPadding: false, contentMode: .fill)
        )
        .background(video.backgroundColor)
        .cornerRadius(15)
        .frame(width: 246, height: 360)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

struct PastEditionCardView_Previews: PreviewProvider {

    static var previews: some View {
        PastEditionCardView(video: Video(title: "The roots", speaker: "Felipe Lefèvre Marino", background: URL(string: "https://google.com")!, link: URL(string: "https://www.cocoaheads.com.br/videos/detalhes/20")!))
    }
}
