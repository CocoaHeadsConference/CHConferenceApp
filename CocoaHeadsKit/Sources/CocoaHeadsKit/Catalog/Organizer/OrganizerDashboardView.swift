import CocoaHeadsCore
import SwiftUI

enum OrganizerWorkspaceDestination: String, CaseIterable, Identifiable {
  case overview, events, triage, announcements, videos, organizers

  static let compactDestinations: [Self] = [.overview, .events, .triage, .announcements]
  var id: Self { self }

  var title: String {
    switch self {
    case .overview: "Visão geral"
    case .events: "Eventos"
    case .triage: "Triagem"
    case .announcements: "Avisos"
    case .videos: "Vídeos"
    case .organizers: "Organizadores"
    }
  }

  var symbol: String {
    switch self {
    case .overview: "square.grid.2x2.fill"
    case .events: "calendar"
    case .triage: "tray"
    case .announcements: "megaphone"
    case .videos: "play.rectangle"
    case .organizers: "person.2"
    }
  }
}

@MainActor
struct OrganizerDashboardView: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  let records: [OrganizerEventRecord]
  let chapterName: String
  let isWide: Bool
  let errorMessage: String?
  let isLoading: Bool
  let onCreate: () -> Void
  let onEdit: (OrganizerEventRecord) -> Void
  let onSelect: (OrganizerWorkspaceDestination) -> Void
  let onRefresh: () async -> Void

  var body: some View {
    TimelineView(.periodic(from: .now, by: 60)) { context in
      let data = OrganizerDashboardData(records: records, now: context.date)
      ScrollView {
        VStack(spacing: 0) {
          chapterBanner
          VStack(alignment: .leading, spacing: 24) {
            if let errorMessage {
              VStack(alignment: .leading, spacing: 8) {
                Text(errorMessage).foregroundStyle(.red)
                Button("Atualizar eventos") { Task { await onRefresh() } }.disabled(isLoading)
              }
            }
            createButton
            metrics(data)
            if isWide {
              HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 24) {
                  nextEventSection(data)
                  draftsSection(data)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                upcomingTools
                  .frame(maxWidth: .infinity, alignment: .topLeading)
              }
            } else {
              nextEventSection(data)
              draftsSection(data)
              upcomingTools
            }
          }
          .padding(isWide ? 28 : 20)
          .frame(maxWidth: 1_180, alignment: .leading)
          .frame(maxWidth: .infinity)
        }
      }
      .background(MataTheme.background)
      .refreshable { await onRefresh() }
    }
  }

  private var chapterBanner: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("ORGANIZAÇÃO · CAPÍTULO", systemImage: "cup.and.saucer.fill")
        .font(.caption.weight(.bold)).tracking(1.2)
        .foregroundStyle(.white.opacity(0.85))
      Text(chapterName).font(.largeTitle.bold()).foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(isWide ? 32 : 24)
    .frame(maxWidth: .infinity, minHeight: isWide ? 156 : 126, alignment: .leading)
    .background {
      LinearGradient(
        colors: [Color(red: 0.04, green: 0.66, blue: 0.36), Color(red: 0.02, green: 0.34, blue: 0.20)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    }
  }

  private var createButton: some View {
    Button(action: onCreate) {
      Label("Criar evento", systemImage: "plus")
        .font(.headline)
        .frame(maxWidth: isWide ? nil : .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, isWide ? 18 : 0)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .disabled(isLoading)
  }

  @ViewBuilder
  private func metrics(_ data: OrganizerDashboardData) -> some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(spacing: 14) { metricCards(data) }
    } else {
      HStack(alignment: .top, spacing: 14) { metricCards(data) }
    }
  }

  @ViewBuilder
  private func metricCards(_ data: OrganizerDashboardData) -> some View {
    OrganizerMetricCard(
      title: data.isOngoing ? "Evento em andamento" : "Próximo evento",
      value: data.nextTiming,
      detail: data.nextEvent.map(OrganizerDashboardData.title(for:)) ?? "Nenhum encontro publicado agendado")
    OrganizerMetricCard(
      title: "Rascunhos", value: String(data.drafts.count),
      detail: data.drafts.isEmpty ? "Nenhuma alteração pendente" : "para revisar e publicar")
  }

  @ViewBuilder
  private func nextEventSection(_ data: OrganizerDashboardData) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionTitle(data.isOngoing ? "Acontecendo agora" : "Próximo evento")
      if let event = data.nextEvent {
        VStack(alignment: .leading, spacing: 18) {
          HStack(alignment: .top, spacing: 14) {
            OrganizerEventDateBadge(draft: event.draft)
            VStack(alignment: .leading, spacing: 6) {
              Text(OrganizerDashboardData.title(for: event)).font(.title3.bold())
              Text(OrganizerDashboardData.dateLine(for: event.draft))
                .font(.subheadline).foregroundStyle(.secondary)
              if let venue = event.draft.venue, event.draft.format != .online {
                Text(venue.name).font(.subheadline).foregroundStyle(.secondary)
              } else if event.draft.format == .online {
                Text("Online").font(.subheadline).foregroundStyle(.secondary)
              }
              if OrganizerDashboardData.hasUnpublishedChanges(event) {
                Text("Há alterações em rascunho")
                  .font(.caption).foregroundStyle(MataTheme.accent)
              }
            }
          }
          ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) { eventActions(event) }
            VStack(alignment: .leading, spacing: 10) { eventActions(event) }
          }
          NavigationLink {
            CocoaHeadsPlaceholder("Inscritos")
              .navigationTitle("Inscritos")
          } label: {
            HStack {
              Label("Inscritos", systemImage: "person.2")
              Spacer()
              Text("Em breve").font(.caption).foregroundStyle(.secondary)
              Image(systemName: "chevron.right").font(.caption)
            }
            .font(.subheadline)
          }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
      } else {
        VStack(alignment: .leading, spacing: 8) {
          Text("Vamos marcar o próximo encontro?").font(.headline)
          Text("Publique um evento com data definida para acompanhá-lo por aqui.")
            .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
      }
    }
  }

  @ViewBuilder
  private func eventActions(_ event: OrganizerEventRecord) -> some View {
    Button("Editar") { onEdit(event) }.buttonStyle(.bordered)
    NavigationLink {
      CocoaHeadsPlaceholder("Check-in").navigationTitle("Check-in")
    } label: {
      Text("Check-in")
    }
    .buttonStyle(.bordered)
    if let url = OrganizerDashboardData.shareURL(for: event) {
      ShareLink(item: url) { Text("Divulgar") }
        .buttonStyle(.borderedProminent)
    }
  }

  private func draftsSection(_ data: OrganizerDashboardData) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        sectionTitle("Rascunhos")
        Spacer()
        if data.drafts.count > 3 {
          Button("Ver todos") { onSelect(.events) }.font(.subheadline)
        }
      }
      if data.drafts.isEmpty {
        Text("Seus próximos rascunhos aparecerão aqui.")
          .font(.subheadline).foregroundStyle(.secondary)
          .padding(20)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
      } else {
        ForEach(data.drafts.prefix(3)) { event in
          Button {
            onEdit(event)
          } label: {
            HStack(spacing: 14) {
              Image(systemName: "square.and.pencil")
                .font(.title2).foregroundStyle(.secondary)
                .frame(width: 48, height: 56)
                .background(MataTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
              VStack(alignment: .leading, spacing: 5) {
                Text(OrganizerDashboardData.title(for: event)).font(.headline).foregroundStyle(.primary)
                Text(event.publishedAt == nil ? "Rascunho" : "Alterações não publicadas")
                  .font(.subheadline).foregroundStyle(.secondary)
              }
              Spacer(minLength: 0)
              Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
            .contentShape(RoundedRectangle(cornerRadius: 24))
          }
          .buttonStyle(.plain)
          .accessibilityHint("Continuar editando o rascunho")
        }
      }
    }
  }

  private var upcomingTools: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionTitle("Mais ferramentas")
      deferredCard(.triage, detail: "Interesses em palestrar e contribuir com o capítulo.")
      deferredCard(.announcements, detail: "Comunicados para a comunidade do seu capítulo.")
    }
  }

  private func deferredCard(_ destination: OrganizerWorkspaceDestination, detail: String) -> some View {
    Button {
      onSelect(destination)
    } label: {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Label(destination.title, systemImage: destination.symbol).font(.headline)
          Spacer()
          Text("Em breve").font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
        Text(detail).font(.subheadline).foregroundStyle(.secondary)
          .multilineTextAlignment(.leading)
      }
      .foregroundStyle(.primary)
      .padding(20)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
      .contentShape(RoundedRectangle(cornerRadius: 24))
    }
    .buttonStyle(.plain)
  }

  private func sectionTitle(_ title: String) -> some View {
    Text(title.uppercased()).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
  }
}

private struct OrganizerMetricCard: View {
  let title: String
  let value: String
  let detail: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
      Text(value).font(.title.bold()).monospacedDigit()
      Text(detail).font(.subheadline).foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(20)
    .frame(maxWidth: .infinity, minHeight: 155, alignment: .topLeading)
    .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
  }
}

struct OrganizerEventDateBadge: View {
  let draft: OrganizerEventDraft

  var body: some View {
    VStack(spacing: 2) {
      if let date = draft.startDate {
        let style = Date.FormatStyle(
          locale: Locale(identifier: "pt_BR"), timeZone: TimeZone(identifier: draft.timezoneID) ?? .current)
        Text(date.formatted(style.month(.abbreviated)).replacingOccurrences(of: ".", with: "").uppercased())
          .font(.caption2.bold())
        Text(date.formatted(style.day())).font(.title2.bold()).monospacedDigit()
      } else {
        Image(systemName: "square.and.pencil").font(.title2)
      }
    }
    .foregroundStyle(MataTheme.accent)
    .frame(width: 64, height: 72)
    .background(MataTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    .accessibilityHidden(true)
  }
}

struct OrganizerDashboardData {
  let drafts: [OrganizerEventRecord]
  let nextEvent: OrganizerEventRecord?
  let now: Date

  init(records: [OrganizerEventRecord], now: Date) {
    self.now = now
    drafts = records.filter(Self.hasUnpublishedChanges).sorted { $0.updatedAt > $1.updatedAt }
    nextEvent =
      records.filter { record in
        guard record.publishedAt != nil, let start = record.draft.startDate else { return false }
        if start > now { return true }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: record.draft.timezoneID) ?? .current
        let end =
          record.draft.endDate ?? calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: start)) ?? start
        return end > now
      }.sorted { ($0.draft.startDate ?? .distantFuture) < ($1.draft.startDate ?? .distantFuture) }.first
  }

  var isOngoing: Bool { nextEvent?.draft.startDate.map { $0 <= now } ?? false }

  var nextTiming: String {
    guard let event = nextEvent, let start = event.draft.startDate else { return "A definir" }
    if isOngoing { return "Agora" }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: event.draft.timezoneID) ?? .current
    let days =
      calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: start)).day ?? 0
    switch days {
    case 0: return "Hoje"
    case 1: return "Amanhã"
    default: return "Em \(days) dias"
    }
  }

  static func hasUnpublishedChanges(_ record: OrganizerEventRecord) -> Bool {
    guard let published = record.publishedAt else { return true }
    return record.updatedAt > published
  }

  static func title(for record: OrganizerEventRecord) -> String {
    let title = record.draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
    return title.isEmpty ? "Evento sem título" : title
  }

  static func dateLine(for draft: OrganizerEventDraft) -> String {
    guard let start = draft.startDate else { return "Data a definir" }
    return start.formatted(
      Date.FormatStyle(
        date: .abbreviated, time: .shortened, locale: Locale(identifier: "pt_BR"),
        timeZone: TimeZone(identifier: draft.timezoneID) ?? .current))
  }

  static func shareURL(for record: OrganizerEventRecord) -> URL? {
    // The contract exposes the working draft, so only share it while it matches the publication.
    guard record.publishedAt != nil, !hasUnpublishedChanges(record) else { return nil }
    let registration = URL(string: record.draft.registrationURL.trimmingCharacters(in: .whitespacesAndNewlines))
    return [record.draft.shareURL, registration].compactMap { $0 }.first {
      ["http", "https"].contains($0.scheme?.lowercased() ?? "") && !($0.host ?? "").isEmpty
        && $0.user == nil && $0.password == nil
    }
  }
}
