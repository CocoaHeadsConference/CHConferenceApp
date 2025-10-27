//
//  MeetupError.swift
//
//
//  Created by Mauricio Cardozo on 10/2/25.
//

public enum MeetupError: Error {
  case dateError
  case urlError

  public var localizedDescription: String {
    switch self {
    case .dateError:
      "Couldn't decode date"
    case .urlError:
      "Invalid URL"
    }
  }
}
