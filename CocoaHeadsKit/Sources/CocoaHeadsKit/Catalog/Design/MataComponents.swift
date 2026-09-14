import CocoaHeadsCore
import CocoaHeadsNetworking
import SwiftUI

enum MataTheme {
  static var accent: Color {
    Color(
      uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
          ? UIColor(red: 0.16, green: 0.81, blue: 0.47, alpha: 1)
          : UIColor(red: 0.02, green: 0.46, blue: 0.25, alpha: 1)
      })
  }

  static var background: Color {
    #if os(visionOS)
      .clear
    #else
      Color(uiColor: .systemGroupedBackground)
    #endif
  }

  static var onAccent: Color {
    Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? .black : .white })
  }

  static var surface: Color {
    #if os(visionOS)
      .white.opacity(0.08)
    #else
      Color(uiColor: .secondarySystemGroupedBackground)
    #endif
  }
}

struct EventDateBadge: View {
  let event: CommunityEvent

  var body: some View {
    VStack(spacing: 0) {
      Text(
        event.startDate.formatted(
          Date.FormatStyle(locale: Locale(identifier: "pt_BR"), timeZone: event.timeZone)
            .month(.abbreviated)
        ).replacingOccurrences(of: ".", with: "").uppercased()
      )
      .font(.caption2.weight(.bold))
      Text(
        event.startDate.formatted(
          Date.FormatStyle(timeZone: event.timeZone).day(.twoDigits))
      )
      .font(.title2.weight(.bold))
      .monospacedDigit()
    }
    .foregroundStyle(MataTheme.accent)
    .frame(minWidth: 64, minHeight: 70)
    .background(MataTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      event.startDate.formatted(
        Date.FormatStyle(
          date: .long, time: .omitted, locale: Locale(identifier: "pt_BR"),
          timeZone: event.timeZone)))
  }
}

struct EventArtwork: View {
  let title: String
  let eyebrow: String
  var subtitle: String? = nil
  var imageURL: URL? = nil
  var cornerRadius: CGFloat = 24
  var fillsAvailableHeight = false

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Spacer(minLength: imageURL == nil ? 0 : 70)
      Text(eyebrow.uppercased()).font(.caption.weight(.bold)).tracking(1.2)
      Text(title).font(.title.weight(.bold)).fixedSize(horizontal: false, vertical: true)
      if let subtitle {
        Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.9))
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .foregroundStyle(.white)
    .padding(24)
    .frame(
      maxWidth: .infinity, minHeight: imageURL == nil ? 180 : 260,
      maxHeight: fillsAvailableHeight ? .infinity : nil, alignment: .bottomLeading
    )
    .background {
      LinearGradient(
        colors: [
          Color(red: 0.04, green: 0.65, blue: 0.36),
          Color(red: 0.02, green: 0.32, blue: 0.19)
        ], startPoint: .topLeading, endPoint: .bottomTrailing
      )
      .overlay {
        if let imageURL {
          CatalogCachedImage(url: imageURL)
            .overlay {
              LinearGradient(
                stops: [
                  .init(color: .black.opacity(0.04), location: 0),
                  .init(color: .black.opacity(0.30), location: 0.3),
                  .init(color: .black.opacity(0.88), location: 1)
                ],
                startPoint: .top, endPoint: .bottom)
            }
        } else {
          GeometryReader { proxy in
            Circle()
              .fill(.white.opacity(0.12))
              .frame(width: 190, height: 190)
              .position(x: proxy.size.width - 24, y: 20)
          }
          .accessibilityHidden(true)
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
  }
}

struct CatalogCachedImage: View {
  let url: URL?
  @Environment(\.eventImageStore) private var imageStore
  @State private var image: UIImage?

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        MataTheme.accent.opacity(0.12)
        if let image {
          Image(uiImage: image).resizable().scaledToFill()
        } else {
          Image(systemName: "cup.and.saucer.fill")
            .font(.title2)
            .foregroundStyle(MataTheme.accent)
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .clipped()
    }
    .clipped()
    .task(id: url) {
      image = nil
      guard let url else { return }
      do {
        let data = try await imageStore.data(for: url)
        try Task.checkCancellation()
        image = UIImage(data: data)
      } catch {
        // Keep a local placeholder if the image is unavailable.
      }
    }
    .accessibilityHidden(true)
  }
}

struct CatalogUpdateRequiredView: View {
  var body: some View {
    ContentUnavailableView {
      Label("Atualize o CocoaHeads", systemImage: "arrow.down.app")
    } description: {
      Text("Uma nova versão do app é necessária para abrir esta tela.")
    } actions: {
      Link("Abrir App Store", destination: URL(string: "https://apps.apple.com/app/id1180455342")!)
        .buttonStyle(.borderedProminent)
    }
  }
}

struct CatalogLoadFailureView: View {
  let retry: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("Não foi possível carregar", systemImage: "wifi.exclamationmark")
    } description: {
      Text("Confira sua conexão e tente novamente.")
    } actions: {
      Button("Tentar novamente", action: retry).buttonStyle(.borderedProminent)
    }
  }
}

struct CatalogRefreshNotice: View {
  let date: Date?
  let retry: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "wifi.exclamationmark").foregroundStyle(.secondary)
      VStack(alignment: .leading, spacing: 3) {
        Text("Não foi possível atualizar.").font(.subheadline.weight(.medium))
        if let date {
          Text(
            "Conteúdo salvo em \(date.formatted(.dateTime.locale(Locale(identifier: "pt_BR")).day().month(.abbreviated).hour().minute()))."
          )
          .font(.caption).foregroundStyle(.secondary)
        }
      }
      Spacer(minLength: 0)
      Button(action: retry) { Image(systemName: "arrow.clockwise") }
        .accessibilityLabel("Tentar atualizar novamente")
        .buttonStyle(.borderless)
        .padding(4)
    }
    .padding(16)
    .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 18))
    .accessibilityElement(children: .contain)
  }
}
