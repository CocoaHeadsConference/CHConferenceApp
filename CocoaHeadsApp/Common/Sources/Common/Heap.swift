//
//  Heap.swift
//  Common
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

private final class Reference<T: Equatable>: Equatable {
  var value: T
  init(_ value: T) {
    self.value = value
  }
  static func == (lhs: Reference<T>, rhs: Reference<T>) -> Bool {
    lhs.value == rhs.value
  }
}

@propertyWrapper public struct Heap<T: Equatable>: Equatable {
  private var reference: Reference<T>

  public init(_ value: T) {
    reference = .init(value)
  }

  public var wrappedValue: T {
    get { reference.value }
    set {
      if !isKnownUniquelyReferenced(&reference) {
        reference = .init(newValue)
        return
      }
      reference.value = newValue
    }
  }
  public var projectedValue: Heap<T> {
    self
  }
}

extension Heap: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension Heap: Decodable where T: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(T.self)
    self = Heap(value)
  }
}

extension Heap: Encodable where T: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}
