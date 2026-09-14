import SwiftUI

/// Drop-in destination for unfinished features. Search for CocoaHeadsPlaceholder to find them.
public struct CocoaHeadsPlaceholder: View {
  private let feature: String

  public init(_ feature: String) {
    self.feature = feature
  }

  public var body: some View {
    ContentUnavailableView {
      Label(feature, systemImage: "cup.and.saucer")
    } description: {
      Text("Estamos preparando esta experiência para você. Em breve, por aqui.")
    }
  }
}

#Preview {
  CocoaHeadsPlaceholder("Quero palestrar")
}
