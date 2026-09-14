import CocoaHeadsCore
import MapKit
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

@MainActor
struct EventDirectionsView: View {
  enum Presentation {
    case standalone
    case embeddedExpandable
    case embeddedExpanded
  }

  let venue: EventVenue
  var presentation: Presentation = .standalone

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var hasGoogleMaps = false
  @State private var hasWaze = false
  @State private var isExpanded = false

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      if presentation == .embeddedExpandable {
        directionsPreview
        if isExpanded {
          locationDetails
          arrivalDetails
          mapsActions
        }
      } else {
        Label("Como chegar", systemImage: "mappin.and.ellipse")
          .font(.title3.weight(.semibold))
          .accessibilityAddTraits(.isHeader)

        if presentation == .standalone {
          locationDetails
        }
        if let coordinates = EventDirectionsLinks.coordinates(for: venue) {
          mapPreview(coordinates: coordinates)
            .frame(height: presentation == .standalone ? 220 : 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        if presentation == .embeddedExpanded {
          locationDetails
        }
        arrivalDetails
        mapsActions
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(presentation == .standalone ? 20 : 0)
    .background {
      if presentation == .standalone {
        RoundedRectangle(cornerRadius: 24).fill(MataTheme.surface)
      }
    }
    .tint(MataTheme.accent)
    .onAppear(perform: refreshAvailableApps)
    .onChange(of: scenePhase) { _, phase in
      if phase == .active { refreshAvailableApps() }
    }
  }

  private var directionsPreview: some View {
    EventSectionPreview(
      title: "Como chegar", subtitle: venue.name,
      systemImage: isExpanded ? "chevron.up" : "chevron.down", isEmbedded: true,
      action: {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
          isExpanded.toggle()
        }
      }
    ) {
      if let coordinates = EventDirectionsLinks.coordinates(for: venue) {
        mapPreview(coordinates: coordinates)
      } else {
        ZStack {
          MataTheme.accent.opacity(0.08)
          Image(systemName: "map")
            .font(.system(size: 58, weight: .light))
            .foregroundStyle(MataTheme.accent.opacity(0.3))
        }
      }
    }
    .accessibilityValue(isExpanded ? "Expandido" : "Recolhido")
    .accessibilityHint(
      isExpanded
        ? "Recolhe as orientações de chegada" : "Mostra o endereço, as orientações de chegada e as opções de mapas")
  }

  private var locationDetails: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(venue.name)
        .font(.headline)
      if let address = EventDirectionsLinks.address(for: venue) {
        Text(address)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
      } else {
        Text("O endereço ainda não foi informado.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .fixedSize(horizontal: false, vertical: true)
  }

  @ViewBuilder
  private var arrivalDetails: some View {
    if let instructions = arrivalInstructions {
      VStack(alignment: .leading, spacing: 6) {
        Text("Orientações de chegada")
          .font(.subheadline.weight(.semibold))
          .accessibilityAddTraits(.isHeader)
        Text(instructions)
          .font(.subheadline)
          .textSelection(.enabled)
      }
      .fixedSize(horizontal: false, vertical: true)
    }
  }

  @ViewBuilder
  private var mapsActions: some View {
    if let appleMapsURL = EventDirectionsLinks.appleMapsURL(for: venue) {
      VStack(alignment: .leading, spacing: 12) {
        Link(destination: appleMapsURL) {
          Label("Abrir no Apple Maps", systemImage: "map")
            .font(.headline)
            .foregroundStyle(MataTheme.onAccent)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityHint("Abre as rotas até o local do evento no Apple Maps")

        if hasGoogleMaps || hasWaze {
          let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 10))
          layout {
            if hasGoogleMaps, let url = EventDirectionsLinks.googleMapsURL(for: venue) {
              Link("Google Maps", destination: url)
                .accessibilityHint("Abre as rotas até o local do evento no Google Maps")
            }
            if hasWaze, let url = EventDirectionsLinks.wazeURL(for: venue) {
              Link("Waze", destination: url)
                .accessibilityHint(
                  EventDirectionsLinks.coordinates(for: venue) == nil
                    ? "Busca o endereço do evento no Waze"
                    : "Abre a navegação até o local do evento no Waze")
            }
          }
          .buttonStyle(.bordered)
          .controlSize(.large)
        }
      }
    }
  }

  private var arrivalInstructions: String? {
    guard let instructions = venue.arrivalInstructions?.trimmingCharacters(in: .whitespacesAndNewlines),
      !instructions.isEmpty
    else { return nil }
    return instructions
  }

  private func mapPreview(coordinates: EventDirectionsLinks.Coordinates) -> some View {
    let location = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    let region = MKCoordinateRegion(center: location, latitudinalMeters: 1_000, longitudinalMeters: 1_000)
    return Map(initialPosition: .region(region), interactionModes: []) {
      Marker(venue.name, coordinate: location)
        .tint(MataTheme.accent)
    }
    .mapStyle(.standard(pointsOfInterest: .excludingAll))
    .id(coordinates)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Mapa de \(venue.name)")
    .accessibilityHint("Use as opções abaixo para abrir as rotas")
  }

  private func refreshAvailableApps() {
    #if canImport(UIKit)
      hasGoogleMaps =
        EventDirectionsLinks.googleMapsAvailabilityURL.map {
          UIApplication.shared.canOpenURL($0)
        } ?? false
      hasWaze =
        EventDirectionsLinks.wazeAvailabilityURL.map {
          UIApplication.shared.canOpenURL($0)
        } ?? false
    #else
      hasGoogleMaps = false
      hasWaze = false
    #endif
  }
}
