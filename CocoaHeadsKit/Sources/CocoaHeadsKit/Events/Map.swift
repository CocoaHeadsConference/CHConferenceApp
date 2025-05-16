//
//  Map.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import MapKit
import SwiftUI

struct MapUI: View {
  let address: String
  let latitude: Double
  let longitude: Double

  var body: some View {
    Button {
      openInMaps()
    } label: {
      Map(initialPosition: position, interactionModes: []) {
        Marker(address, image: "", coordinate: location)
      }
    }
    .frame(height: 200)
    .contextMenu {
      Button(action: openInMaps) {
        Label("Abrir no Maps", systemImage: "map")
      }
      if let wazeURL {
        Link(destination: wazeURL) {
          Label("Abrir no Waze", systemImage: "car")
        }
      }
      Button {
        UIPasteboard.general.string = address
      } label: {
        Label("Copiar endereço", systemImage: "document.on.document")
      }
      ShareLink(item: address) {
        Label("Compartilhar endereço", systemImage: "square.and.arrow.up")
      }
    }
    .mask {
      RoundedRectangle(cornerRadius: 10, style: .continuous)
    }
  }

  private var location: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

  private var position: MapCameraPosition {
    .region(
      .init(
        center: location,
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
      )
    )
  }

  private func openInMaps() {
    MKMapItem(
      placemark: MKPlacemark(
        coordinate: location
      )
    ).openInMaps()
  }

  private var wazeURL: URL? {
    // https://developers.google.com/waze/deeplinks
    guard
      let urlEncoded = address.stringByAddingPercentEncodingForRFC3986(),
      let url = URL(string: "https://waze.com/ul?q=\(urlEncoded)&navigate=yes")
    else {
      return nil
    }
    return url
  }
}

#Preview {
  MapUI(
    address: "Rua Butantã 194, São Paulo - SP",
    latitude: -23.569160,
    longitude: -46.697270
  )
}

extension String {
  fileprivate func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}
