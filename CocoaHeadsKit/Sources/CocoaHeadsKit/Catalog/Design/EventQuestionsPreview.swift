import SwiftUI

struct EventQuestionsPreview: View {
  var isEmbedded = false
  let action: () -> Void

  var body: some View {
    EventSectionPreview(
      title: "Perguntas", subtitle: "Entre na conversa", isEmbedded: isEmbedded,
      action: action
    ) {
      VStack(alignment: .leading, spacing: 10) {
        previewRow(question: "Por onde começar a aprender?", lineWidth: 0.62)
        previewRow(question: "Como vocês usam isso no dia a dia?", lineWidth: 0.82)
      }
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .padding(14)
      .frame(maxHeight: .infinity, alignment: .top)
    }
    .accessibilityHint("Abre as perguntas e respostas do evento.")
  }

  private func previewRow(question: String, lineWidth: CGFloat) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "bubble.left")
        .foregroundStyle(MataTheme.accent.opacity(0.6))
        .frame(width: 28, height: 28)

      VStack(alignment: .leading, spacing: 8) {
        Text(question)
          .lineLimit(1)
        GeometryReader { proxy in
          Capsule()
            .fill(.secondary.opacity(0.12))
            .frame(width: proxy.size.width * lineWidth, height: 5)
        }
        .frame(height: 5)
      }

      Image(systemName: "arrow.up")
        .font(.caption.weight(.semibold))
        .padding(8)
        .background(MataTheme.accent.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
    }
    .padding(10)
    .background(MataTheme.accent.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
  }
}

/// A decorative section preview with one accessible action above a surface fade.
struct EventSectionPreview<Preview: View>: View {
  let title: String
  let subtitle: String
  var systemImage = "chevron.right"
  var isEmbedded = false
  let action: () -> Void
  @ViewBuilder let preview: () -> Preview

  private var fadeSurface: Color {
    Color(uiColor: .secondarySystemGroupedBackground)
  }

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .center, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text(title)
              .font(.title3.weight(.bold))
              .foregroundStyle(.primary)
            Text(subtitle)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .fixedSize(horizontal: false, vertical: true)
          Spacer(minLength: 0)
          Image(systemName: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(MataTheme.accent)
            .frame(width: 36, height: 36)
            .background(MataTheme.accent.opacity(0.12), in: Circle())
        }
        .padding(18)
      }
      .background {
        preview()
          .overlay {
            LinearGradient(
              stops: [
                .init(color: fadeSurface.opacity(0.05), location: 0),
                .init(color: fadeSurface.opacity(0.85), location: 0.45),
                .init(color: fadeSurface, location: 0.85)
              ], startPoint: .top, endPoint: .bottom)
          }
          .clipped()
          .allowsHitTesting(false)
          .accessibilityHidden(true)
      }
      .background(fadeSurface)
      .overlay {
        if !isEmbedded {
          RoundedRectangle(cornerRadius: 20)
            .strokeBorder(MataTheme.accent.opacity(0.1), lineWidth: 1)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: isEmbedded ? 12 : 20))
      .contentShape(RoundedRectangle(cornerRadius: isEmbedded ? 12 : 20))
    }
    .buttonStyle(.plain)
    .hoverEffect(.highlight)
    .accessibilityElement(children: .ignore)
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel(title)
  }
}
