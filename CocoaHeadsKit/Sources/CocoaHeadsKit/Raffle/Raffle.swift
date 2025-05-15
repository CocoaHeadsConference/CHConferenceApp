//
//  Raffle.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/15/25.
//

import SwiftUI

enum RaffleState {
  case noRaffle  // No raffle for id or user does not have iCloud
  case closed
  case notSubmitted
  case submitted
  case winner
  case loser
  case closedWithWinner
}
