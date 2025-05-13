//
//  TicketImage.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/13/25.
//

import SwiftUI

struct TicketImage: Transferable {
  let image: Image

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      #if canImport(AppKit)
        guard let nsImage = NSImage(data: data) else {
          throw Error.decodingError
        }
        let image = Image(nsImage: nsImage)
        return TicketImage(image: image)
      #elseif canImport(UIKit)
        guard let uiImage = UIImage(data: data) else {
          throw Error.decodingError
        }
        let image = Image(uiImage: uiImage)
        return TicketImage(image: image)
      #else
        throw TransferError.importFailed
      #endif
    }
  }

  enum Error: Swift.Error {
    case decodingError
  }
}
