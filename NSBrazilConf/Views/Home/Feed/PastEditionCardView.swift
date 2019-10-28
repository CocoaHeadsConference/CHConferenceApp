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
        VStack(alignment: .center) {
            Text(video.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(.top, 24)
                .padding()
                .lineLimit(4)
                .frame(width: 240)
            Text(video.speaker)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding()
                .lineLimit(1)
            Spacer()
            Image("ic_play")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)
                .padding()
            Spacer()
            
        }
        .background(video.backgroundColor)
        .cornerRadius(30)
        .frame(width: 246, height: 360)
        .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 0)
    }
}

struct PastEditionCardView_Previews: PreviewProvider {

    static var previews: some View {
        PastEditionCardView(video: Video(title: "GraphQL no iOS na Prática", speaker: "Felipe Lefèvre Marino", background: URL(string: "https://google.com")!, link: URL(string: "https://www.cocoaheads.com.br/videos/detalhes/20")!))
    }
}
