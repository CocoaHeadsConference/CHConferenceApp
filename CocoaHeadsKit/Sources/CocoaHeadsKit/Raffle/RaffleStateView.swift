//
//  RaffleStateView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/15/25.
//

import CoreHaptics
import SwiftUI

struct RaffleStateView: View {
  let state: RaffleState
  @Binding var textField: String
  var onSubmit: () -> Void

  @ViewBuilder var body: some View {
    ZStack {
      switch state {
      case .noRaffle:
        Text("👀")
      case .closed:
        Text("👀")
      case .notSubmitted:
        submitView
      case .submitted:
        submittedView
      case .winner:
        winnerView
      case .loser:
        loserView
      case .closedWithWinner:
        Text("👀")
      }
    }
    .animation(.default, value: state)
  }

  @State private var isButtonLoading = false

  @ViewBuilder var submitView: some View {
    VStack {
      TextField("Seu nome", text: $textField)
      Button {
        isButtonLoading = true
        onSubmit()
      } label: {
        if isButtonLoading {
          ProgressView()
            .tint(.white)
        } else {
          Text("Quero ganhar")
        }
      }
      .buttonStyle(CallToAction())
      .disabled(textField.isEmpty || isButtonLoading)
    }
  }

  @ViewBuilder var submittedView: some View {
    Text("Agora é só esperar e torcer")
  }

  // TODO: Add confetti effects onAppear
  @ViewBuilder var winnerView: some View {
    VStack {
      Image(systemName: "flag.pattern.checkered.2.crossed")
      Text("Parabéns! Você ganhou!")
    }
    .onAppear {
      do {
        let engine = try CHHapticEngine()
        try engine.start()

        let event = CHHapticEvent(
          eventType: .hapticContinuous,
          parameters: [
            .init(parameterID: .hapticIntensity, value: 1.0),
            .init(parameterID: .hapticSharpness, value: 0.5)
          ],
          relativeTime: 0,
          duration: 5.0
        )

        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: 0)
      } catch {
        print("Haptics failed: \(error)")
      }
    }
  }

  @ViewBuilder var loserView: some View {
    VStack {
      Image(.sad)
      Text("Não foi dessa vez")
    }
  }
}

#Preview("No Raffle") {
  Card {
    RaffleStateView(
      state: .noRaffle,
      textField: .constant("")
    ) {}
  }
}

#Preview("Closed") {
  Card {
    RaffleStateView(
      state: .closed,
      textField: .constant("")
    ) {}
  }
}

#Preview("Not Submitted - Empty") {
  Card {
    RaffleStateView(
      state: .notSubmitted,
      textField: .constant("")
    ) {}
  }
}

#Preview("Not Submitted") {
  Card {
    RaffleStateView(
      state: .notSubmitted,
      textField: .constant("Max Verstappen")
    ) {}
  }
}

#Preview("Submitted") {
  Card {
    RaffleStateView(
      state: .submitted,
      textField: .constant("")
    ) {}
  }
}

#Preview("Winner") {
  Card {
    RaffleStateView(
      state: .winner,
      textField: .constant("")
    ) {}
  }
}

#Preview("Loser") {
  Card {
    RaffleStateView(
      state: .loser,
      textField: .constant("")
    ) {}
  }
}

#Preview("Closed With Winner") {
  Card {
    RaffleStateView(
      state: .closedWithWinner,
      textField: .constant("")
    ) {}
  }
}
