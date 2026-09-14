//
//  EventDetailSections.swift
//  CocoaHeadsKit
//
//  Content blocks rendered below the hero on the catalog event detail screen:
//  information cards, speakers, description, links and the Q&A entry point.
//

import CocoaHeadsCore
import QAKit
import SwiftUI

// MARK: - Section header

struct EventDetailSectionHeader: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.title3.weight(.semibold))
      .foregroundStyle(.primary)
      .accessibilityAddTraits(.isHeader)
  }
}

// MARK: - Information cards (date/time, online)

struct EventDetailInfoCards: View {
  let event: CommunityEvent
  let phase: EventPhase

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var sizeClass
  @Environment(\.openURL) private var openURL

  var body: some View {
    let models = cards
    let stacked = dynamicTypeSize.isAccessibilitySize || (models.count > 2 && sizeClass == .compact)
    let layout =
      stacked
      ? AnyLayout(VStackLayout(spacing: 12))
      : AnyLayout(HStackLayout(alignment: .top, spacing: 12))

    layout {
      ForEach(models) { card in
        EventDetailInfoCard(card: card)
      }
    }
    .fixedSize(horizontal: false, vertical: true)
  }

  private var cards: [EventDetailInfoCardModel] {
    var cards = [dateCard]
    if event.format != .inPerson {
      cards.append(onlineCard)
    }
    return cards
  }

  private var dateCard: EventDetailInfoCardModel {
    let dateLine = EventDetailFormatting.dateLine(for: event)
    let timeLine = EventDetailFormatting.timeLine(for: event)
    let phaseLabel = EventDetailFormatting.phaseLabel(phase, for: event)
    let timeZoneNote = EventDetailFormatting.timeZoneNote(for: event)

    var detail = timeLine
    if let timeZoneNote {
      detail += "\n" + timeZoneNote
    }

    let accessible = [
      dateLine,
      EventDetailFormatting.accessibleTimeLine(for: event),
      timeZoneNote,
      phaseLabel
    ]
    .compactMap { $0 }
    .joined(separator: ", ")

    return EventDetailInfoCardModel(
      id: "date",
      systemImage: "clock",
      title: dateLine,
      detail: detail,
      caption: phaseLabel,
      accessibilityLabel: accessible,
      action: nil
    )
  }

  private var onlineCard: EventDetailInfoCardModel {
    let url = event.onlineURL
    let host = url?.host()
    return EventDetailInfoCardModel(
      id: "online",
      systemImage: "video",
      title: event.format == .hybrid ? "Transmissão online" : "Online",
      detail: host ?? "O link será divulgado pelo capítulo",
      caption: url == nil ? nil : "Abrir link",
      accessibilityLabel: host.map { "Online em \($0)" } ?? "Online",
      action: url.map { url in { openURL(url) } }
    )
  }
}

struct EventDetailInfoCardModel: Identifiable {
  let id: String
  let systemImage: String
  let title: String
  let detail: String?
  let caption: String?
  let accessibilityLabel: String
  let action: (() -> Void)?
}

private struct EventDetailInfoCard: View {
  let card: EventDetailInfoCardModel

  var body: some View {
    Group {
      if let action = card.action {
        Button(action: action) { content }
          .buttonStyle(.plain)
          .hoverEffect()
          .accessibilityAddTraits(.isLink)
      } else {
        content
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(card.accessibilityLabel)
  }

  private var content: some View {
    VStack(alignment: .leading, spacing: 12) {
      Image(systemName: card.systemImage)
        .font(.title3)
        .foregroundStyle(MataTheme.accent)

      VStack(alignment: .leading, spacing: 4) {
        Text(card.title)
          .font(.headline)
          .foregroundStyle(.primary)
        if let detail = card.detail {
          Text(detail)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        if let caption = card.caption {
          Text(caption)
            .font(.footnote.weight(.medium))
            .foregroundStyle(MataTheme.accent)
            .padding(.top, 2)
        }
      }
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding(16)
    .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

// MARK: - Speakers

struct EventDetailSpeakers: View {
  let talks: [EventTalk]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      EventDetailSectionHeader(title: talks.count == 1 ? "Palestrante" : "Palestrantes")

      VStack(spacing: 0) {
        ForEach(Array(talks.enumerated()), id: \.element.id) { index, talk in
          EventDetailSpeakerRow(talk: talk)
          if index < talks.count - 1 {
            Divider().padding(.leading, 16)
          }
        }
      }
      .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
  }
}

private struct EventDetailSpeakerRow: View {
  let talk: EventTalk

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
      : AnyLayout(HStackLayout(alignment: .top, spacing: 14))

    layout {
      EventDetailSpeakerAvatar(name: talk.speakerName, url: talk.speakerImageURL)

      VStack(alignment: .leading, spacing: 4) {
        Text(talk.speakerName)
          .font(.headline)
          .foregroundStyle(.primary)
        if let role = talk.speakerRole, !role.isEmpty {
          Text(role)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Text(talk.title)
          .font(.body)
          .foregroundStyle(.primary)
          .padding(.top, 4)
      }
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(16)
    .accessibilityElement(children: .combine)
  }
}

private struct EventDetailSpeakerAvatar: View {
  let name: String
  let url: URL?

  private let size: CGFloat = 56

  var body: some View {
    Group {
      if let url {
        CatalogCachedImage(url: url)
      } else {
        ZStack {
          Circle().fill(MataTheme.accent.opacity(0.15))
          Text(EventDetailFormatting.initials(for: name))
            .font(.headline)
            .foregroundStyle(MataTheme.accent)
        }
      }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .accessibilityHidden(true)
  }
}

// MARK: - Description

struct EventDetailSummary: View {
  let summary: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      EventDetailSectionHeader(title: "Sobre o evento")
      Text(summary)
        .font(.body)
        .foregroundStyle(.primary)
        .lineSpacing(4)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .textSelection(.enabled)
    }
  }
}

// MARK: - Links

struct EventDetailLinks: View {
  let links: [EventLink]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      EventDetailSectionHeader(title: "Links")

      VStack(spacing: 0) {
        ForEach(Array(links.enumerated()), id: \.element.id) { index, link in
          Link(destination: link.url) {
            HStack(spacing: 12) {
              Text(link.title)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
              Spacer(minLength: 0)
              Image(systemName: "arrow.up.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MataTheme.accent)
            }
            .padding(16)
            .contentShape(Rectangle())
          }
          .hoverEffect()
          if index < links.count - 1 {
            Divider().padding(.leading, 16)
          }
        }
      }
      .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
  }
}

// MARK: - Q&A entry (opens the existing QAKit list in a sheet)

struct EventDetailQAEntry: View {
  let sessionID: String

  @State private var isPresentingQA = false

  var body: some View {
    EventQuestionsPreview {
      isPresentingQA = true
    }
    .sheet(isPresented: $isPresentingQA) {
      QAListView(sessionID: sessionID)
    }
  }
}
