//
//  RaffleCreationView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/15/25.
//

import SwiftUI

struct RaffleCreationView: View {

  @State private var isLoading = false
  @State private var error = ""
  @State private var raffleID: String = "67sp"
  @State private var raffle: Raffle?
  @Environment(\.cloudKitService) var cloudKit

  public var body: some View {
    List {
      Section {
        if isLoading {
          ProgressView()
        } else {
          TextField("id", text: $raffleID)
          Button("Create or Fetch") {
            Task {
              await createOrFetchRaffle()
            }
          }
        }
      }

      if !error.isEmpty {
        Text(error)
      }

      raffleView
    }
  }

  @ViewBuilder var raffleView: some View {
    if let raffle {
      Section {
        Text("Name: \(raffle.name)")
        Text("Winner: \(raffle.winner?.name ?? "No winner")")
        Toggle("Live", isOn: .constant(raffle.isOpen))
          .onSubmit {
            print("toggled")
          }
        NavigationLink("Pick a Winner") {
          RafflePickView(raffle: raffle)
        }
      }
    }
  }

  func createOrFetchRaffle() async {
    isLoading = true
    guard !raffleID.isEmpty else { return }
    do {
      raffle = try await cloudKit.createRaffle(name: raffleID)
    } catch {
      self.error = error.localizedDescription
    }
    isLoading = false
  }
}

struct RafflePickView: View {

  let raffle: Raffle
  @Environment(\.cloudKitService) var cloudKit
  @State private var entries: [RaffleEntry] = []
  @State private var angle: Angle = .zero
  @State private var animateWheel = false
  @State private var winner: RaffleEntry?
  @State private var isPickingWinner = false

  var body: some View {
    VStack {
      Spacer()
      RecursiveWheel(radius: 150, rotation: angle) {
        ForEach(entries) { entry in
          RecursiveWheelComponent {
            Text(name(for: entry))
              .foregroundStyle(.white)
              .padding()
              .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                  .fill(Color.buttonTopGradient)
              }
          }
        }
      }
      .animation(
        .linear(duration: 6).repeatForever(autoreverses: false),
        value: animateWheel
      )
      .animation(.default, value: entries)
      .blur(radius: winner == nil ? 0 : 1)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .background {
      Rectangle().fill(.quinary)
        .ignoresSafeArea()
    }
    .overlay {
      if let winner {
        VStack {
          Text("Parabéns!")
            .font(.title2)
          Text(winner.name)
            .font(.largeTitle)
        }
        .foregroundStyle(.white)
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color.buttonBottomGradient)
        }
      }
    }
    .animation(.default, value: winner)
    .safeAreaInset(edge: .bottom) {
      Button {
        animateWheel = false
        Task {
          await pickWinner()
        }
      } label: {
        if isPickingWinner {
          ProgressView()
            .tint(.white)
        } else {
          Text("Sortear")
        }
      }
      .buttonStyle(CallToAction())
      .padding()
    }
    .onAppear {
      animateWheel = true
      angle = .degrees(360)
    }
    .task {
      await listenToEntries()
    }
    .onDisappear {
      Task {
        await cloudKit.stopListeningToEntries()
      }
    }
  }

  func pickWinner() async {
    guard let winningEntry = entries.randomElement() else { return }
    do {
      isPickingWinner = true
      try await cloudKit.setWinner(for: raffle.id, winnerID: winningEntry.cloudKitIdentifier)
      try await Task.sleep(for: .seconds(10))
      isPickingWinner = false
      winner = winningEntry
    } catch {
      print("pickWinner", error)
    }
  }

  func name(for entry: RaffleEntry) -> String {
    let firstName = String(entry.name.split(separator: " ").first ?? "")
    return if firstName.isEmpty {
      entry.name
    } else {
      firstName
    }
  }

  func listenToEntries() async {
    do {
      entries = try await cloudKit.fetchEntries(for: raffle.id)
    } catch {
      // No entries made yet
    }

    for await newEntry in await cloudKit.listenToEntries(for: raffle.id) {
      entries.append(newEntry)
    }
  }
}
