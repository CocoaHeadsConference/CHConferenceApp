//
//  NSClipApp.swift
//  NSClip
//
//  Created by Mauricio Cardozo on 1/15/21.
//  Copyright © 2021 Cocoaheadsbr. All rights reserved.
//

import NSBrazilLib
import SwiftUI

@main
struct NSClipApp: App {

    @StateObject var feedModel = FeedViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch feedModel.isLoading {
                case .loading:
                    ProgressView()
                case .loaded:
                    loadedBody
                case .failed:
                    errorBody
                }
            }
        }
    }

    var loadedBody: some View {
        VStack {
            DownloadCallToAction()
                .padding(.bottom)
            ScheduleListView(viewModel: feedModel)
        }
    }

    var errorBody: some View {
        VStack(spacing: 20) {
            Text("Algo deu errado")
                .font(Font.title.bold())

            Button(action: {
                self.feedModel.fetchInfo()
            }, label: {
                Text("Tentar novamente")
            })
        }
    }
}
