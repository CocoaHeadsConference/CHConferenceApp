//
//  Date+IdentifiableTest.swift
//  Common
//
//  Created by Mauricio Cardozo on 04/08/24.
//

@testable import Common
import Foundation
import Testing

@Suite("Date+Identifiable testing")
struct DateIdentifiableTest {

  @Test("should return a ISO6804 formatted string for any given date")
  func shouldReturnISO6804FormattedString() {
    let date = Date(timeIntervalSinceReferenceDate: 0)
    #expect(date.id == "2001-01-01T00:00:00Z")
  }
}
