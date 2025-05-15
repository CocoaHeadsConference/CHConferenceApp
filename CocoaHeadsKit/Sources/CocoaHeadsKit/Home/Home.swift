//
//  Home.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 4/28/25.
//

import SwiftUI

// TODO: Kill all of this, replace with server-driven logic and tca

public struct HomePage: View {
  public init() {}
  public var body: some View {
    Page(slug: "local-home")
      .onAppear {
        UIApplication.shared.registerForRemoteNotifications()
      }
  }
}

struct Home: View {
  enum ViewState {
    case loaded([Chapter])
    case error
    case loading
  }

  @State private var state = ViewState.loading
  @Environment(\.cloudKitService) var cloudKit

  public var body: some View {
    VStack {
      switch state {
      case .loading:
        ProgressView()
      case .loaded(let chapters):
        NavigationStack {
          LoadedHome(chapters: chapters)
            .refreshable {
              Task {
                await fetchData()
              }
            }
        }
      case .error:
        ContentUnavailableView {
          Text("Algum erro ocorreu")
        } actions: {
          Button {
            Task {
              await fetchData()
            }
          } label: {
            Text("Tentar novamente")
          }
        }
      }
    }
    .task {
      await Config.fetchEnvironment()
      await fetchData()
    }
  }

  private func fetchData() async {
    state = .loading
    do {
      let chapters = try await cloudKit.fetchData()
      state = .loaded(chapters)
    } catch {
      state = .error
    }

    _ = try? await cloudKit.fetchLeaderAccess()
  }
}

struct LoadedHome: View {

  let chapters: [Chapter]

  // TODO: Chapter selection logic
  // The default chapter should be: The first one from the list that has a future event
  // When the user picks a different chapter, their preference should be saved and that should be the first one instead
  @State private var selectedChapter: Chapter?
  @State private var shouldShowButton = false

  @State private var dragOffset: CGFloat = 0
  @State private var buttonVisibilityTimer: Timer?

  var body: some View {
    ScrollView {
      ZStack(alignment: .leading) {
        NavigationTitle("Eventos")
          .frame(maxWidth: .infinity, alignment: .leading)
          .offset(x: dragOffset)
          .gesture(drag)
        NavigationLink {
          Debug()
        } label: {
          Image(systemName: "gearshape")
            .font(.title)
            .fontWeight(.light)
            .tint(.primary)
        }
        .opacity(shouldShowButton ? 1 : 0)
        .animation(.default, value: shouldShowButton)
      }
      .padding()
      ChapterSelectionView(
        selectedChapter: $selectedChapter,
        availableChapters: chapters
      )
      EventList(events: selectedChapter?.events ?? [])
    }
    .animation(.default, value: dragOffset)
    .onAppear {
      selectedChapter = chapters.first(where: {
        !$0.events.isEmpty
      })
    }
    .animation(.interactiveSpring, value: selectedChapter)
  }

  var drag: some Gesture {
    DragGesture(minimumDistance: 100)
      .onChanged { [$shouldShowButton] value in
        // Only allow dragging to the right
        if value.translation.width > 0 {
          dragOffset = value.translation.width

          // Start the visibility timer if the drag goes beyond 200
          if dragOffset > 200, buttonVisibilityTimer == nil {
            let timeInterval = Config.isTestflightOrDebug ? 0.0 : 3.0
            buttonVisibilityTimer = Timer.scheduledTimer(
              withTimeInterval: timeInterval,
              repeats: false
            ) { _ in
              $shouldShowButton.wrappedValue = true
            }
          }
        }
      }
      .onEnded { _ in
        dragOffset = 0
        shouldShowButton = false
        buttonVisibilityTimer?.invalidate()
        buttonVisibilityTimer = nil
      }
  }
}

#Preview {
  Home()
}

#Preview("Loaded") {
  LoadedHome(
    chapters: [
      .mock("São Paulo")
    ]
  )
}
