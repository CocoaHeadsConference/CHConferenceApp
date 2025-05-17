//
//  RaffleView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/15/25.
//

import SwiftUI

// TODO: Make a view/modifier for TestFlight/Debug-specific views

struct RaffleView: View {

  let id: String
  @State private var isLoading = true
  @State private var hasError = false
  @State private var raffle: Raffle?
  @State private var entry: RaffleEntry?
  @State private var textField = ""
  @Environment(\.cloudKitService) private var cloudKit

  var body: some View {
    VStack {
      if !(ProcessInfo.processInfo.isiOSAppOnMac || Bundle.main.isAppClip || hasError) {
        Card {
          RaffleStateView(
            state: raffleState,
            textField: $textField
          ) {
            Task {
              await submitName()
            }
          }
        }
        .task {
          await fetchRaffle()
          await fetchExistingEntry()
          await listenToRaffleUpdates()
        }
        .onDisappear {
          Task {
            await cloudKit.stopListeningToEntries()
          }
        }
      }
    }
  }

  var raffleState: RaffleState {
    guard !hasError else { return .noRaffle }
    guard let raffle else { return .noRaffle }
    guard !isLoading else { return .noRaffle }

    guard raffle.isOpen else {
      return raffle.winner != nil
        ? .closedWithWinner
        : .closed
    }

    guard let entry else {
      return .notSubmitted
    }

    guard let winner = raffle.winner else {
      return .submitted
    }

    print(winner, entry)
    return winner.cloudKitIdentifier == entry.cloudKitIdentifier
      ? .winner
      : .loser
  }

  func fetchRaffle() async {
    do {
      self.raffle = try await cloudKit.fetchRaffle(name: id)
    } catch {
      // Non existent raffle
    }
  }

  func fetchExistingEntry() async {
    do {
      try await cloudKit.container.userRecordID()
    } catch {
      hasError = true
      return
    }

    do {
      guard let raffle else {
        return
      }
      let entry = try await cloudKit.fetchEntry(raffleID: raffle.id, cloudKitIdentifier: id)
      self.entry = entry
    } catch {
      // This means this user has not entered the raffle yet
    }
  }

  func listenToRaffleUpdates() async {
    guard let raffle else {
      return
    }
    isLoading = false
    for await raffle in await cloudKit.listenToRaffle(for: raffle.id) {
      self.raffle = raffle
    }
  }

  func submitName() async {
    guard let raffle else { return }
    do {
      let id = try await cloudKit.container.userRecordID().recordName
      entry = try await cloudKit.addEntry(
        RaffleEntry(
          name: textField,
          identifier: id,
          raffleIdentifier: raffle.id))
    } catch {
      print("raffleView submitName", error)
    }
  }
}
