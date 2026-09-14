import CocoaHeadsCore
import CocoaHeadsNetworking
import SwiftUI

@MainActor
struct OrganizerHomeView: View {
  @Environment(CocoaHeadsAppServices.self) private var services
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.scenePhase) private var scenePhase
  @State private var access: OrganizerAccess?
  @State private var records: [OrganizerEventRecord] = []
  @State private var chapterID = ""
  @State private var destination = OrganizerWorkspaceDestination.overview
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var editor: EditorRoute?

  let onClose: () -> Void

  init(onClose: @escaping () -> Void) {
    self.onClose = onClose
  }

  private struct EditorRoute: Identifiable {
    let id = UUID()
    let record: OrganizerEventRecord?
  }

  private var canOrganize: Bool {
    guard let access, let user = services.session.user, user.id == access.user.id else { return false }
    return (user.role == .organizer || user.role == .admin) && !access.chapters.isEmpty
  }

  private var chapterName: String {
    if let chapter = access?.chapters.first(where: { $0.id == chapterID }) { return chapter.name }
    return access?.chapters.count == 1 ? access?.chapters.first?.name ?? "Organização" : "Todos os capítulos"
  }

  private var visibleRecords: [OrganizerEventRecord] {
    let allowed = Set(access?.chapters.map(\.id) ?? [])
    return records.filter {
      allowed.contains($0.draft.chapterID) && (chapterID.isEmpty || $0.draft.chapterID == chapterID)
    }.sorted { $0.updatedAt > $1.updatedAt }
  }

  var body: some View {
    GeometryReader { geometry in
      let isWide = geometry.size.width >= 800 && !dynamicTypeSize.isAccessibilitySize
      Group {
        if isWide {
          NavigationSplitView {
            sidebar
          } detail: {
            destinationStack(destination, isWide: true)
          }
          .navigationSplitViewStyle(.balanced)
        } else {
          TabView(selection: $destination) {
            ForEach(OrganizerWorkspaceDestination.compactDestinations) { item in
              Tab(item.title, systemImage: item.symbol, value: item) {
                destinationStack(item, isWide: false)
                  .toolbarVisibility(.visible, for: .tabBar)
              }
            }
          }
        }
      }
      .onChange(of: isWide) { _, wide in
        if !wide, !OrganizerWorkspaceDestination.compactDestinations.contains(destination) {
          destination = .overview
        }
      }
    }
    .tint(MataTheme.accent)
    .task {
      if services.session.user == nil { onClose() } else { await refresh() }
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active { Task { await refresh() } }
    }
    .sheet(item: $editor, onDismiss: { Task { await refresh() } }) { route in
      NavigationStack {
        OrganizerEventEditor(
          record: route.record, chapters: access?.chapters ?? [],
          initialChapterID: chapterID.isEmpty ? nil : chapterID,
          onSave: install)
      }
    }
    .onChange(of: services.session.user?.id) { _, userID in
      if userID == nil {
        editor = nil
        records = []
        access = nil
        onClose()
      }
    }
  }

  private var sidebar: some View {
    List(
      selection: Binding<OrganizerWorkspaceDestination?>(
        get: { destination }, set: { if let selected = $0 { destination = selected } }
      )
    ) {
      Section {
        Label("CocoaHeads Brasil", systemImage: "cup.and.saucer.fill")
          .font(.headline).foregroundStyle(MataTheme.accent)
        chapterPicker
      }
      Section("Organização") {
        ForEach(OrganizerWorkspaceDestination.allCases) { item in
          Label(item.title, systemImage: item.symbol).tag(item)
        }
      }
    }
    .navigationTitle("Seu capítulo")
    .navigationSplitViewColumnWidth(min: 230, ideal: 280, max: 340)
    .safeAreaInset(edge: .bottom) {
      Button(action: onClose) {
        HStack(spacing: 12) {
          Image(systemName: "person.crop.circle.fill").font(.largeTitle)
          VStack(alignment: .leading, spacing: 3) {
            Text("Voltar ao Perfil").font(.headline)
            Text(services.session.user?.fullName ?? "Sua conta")
              .font(.caption).foregroundStyle(.secondary)
          }
          Spacer()
          Image(systemName: "chevron.backward").font(.caption)
        }
        .padding()
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .background(.bar)
    }
  }

  private func destinationStack(_ item: OrganizerWorkspaceDestination, isWide: Bool) -> some View {
    NavigationStack {
      Group {
        if canOrganize {
          switch item {
          case .overview:
            OrganizerDashboardView(
              records: visibleRecords, chapterName: chapterName, isWide: isWide,
              errorMessage: errorMessage, isLoading: isLoading,
              onCreate: { editor = EditorRoute(record: nil) },
              onEdit: { editor = EditorRoute(record: $0) },
              onSelect: { destination = $0 }, onRefresh: refresh)
          case .events:
            eventsList
          default:
            CocoaHeadsPlaceholder(item.title)
          }
        } else {
          accessView
        }
      }
      .navigationTitle(item.title)
      .toolbarTitleDisplayMode(isWide ? .inline : .large)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Perfil", systemImage: "person.crop.circle", action: onClose)
            .labelStyle(.titleAndIcon)
        }
        if !isWide, canOrganize {
          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              chapterPicker
            } label: {
              Label(chapterName, systemImage: "mappin.and.ellipse")
            }
          }
        }
        if item == .events, canOrganize {
          ToolbarItem(placement: .primaryAction) {
            Button("Criar evento", systemImage: "plus") { editor = EditorRoute(record: nil) }
              .disabled(isLoading)
          }
        }
      }
    }
  }

  @ViewBuilder
  private var chapterPicker: some View {
    if let access, access.chapters.count > 1 {
      Picker("Capítulo", selection: $chapterID) {
        Text("Todos os capítulos").tag("")
        ForEach(access.chapters) { chapter in Text(chapter.name).tag(chapter.id) }
      }
    } else {
      Label(chapterName, systemImage: "mappin.and.ellipse")
    }
  }

  private var accessView: some View {
    List {
      if let errorMessage {
        Section {
          Text(errorMessage).foregroundStyle(.red)
          Button("Atualizar acesso") { Task { await refresh() } }.disabled(isLoading)
        }
      }
      if isLoading {
        ProgressView("Carregando organização…")
      } else if access != nil {
        ContentUnavailableView {
          Label("Acesso à organização", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
          if services.session.user?.role == .user {
            Text("Um administrador precisa liberar seu acesso para organizar eventos.")
          } else {
            Text(
              "Sua conta ainda não tem capítulos disponíveis para organizar. Peça a um administrador para conferir seu acesso."
            )
          }
        } actions: {
          Button("Voltar ao Perfil", action: onClose)
        }
      }
    }
    .refreshable { await refresh() }
  }

  private var eventsList: some View {
    List {
      if let errorMessage {
        Section {
          Text(errorMessage).foregroundStyle(.red)
          Button("Atualizar eventos") { Task { await refresh() } }.disabled(isLoading)
        }
      }
      let drafts = visibleRecords.filter { $0.publishedAt == nil }
      let published = visibleRecords.filter { $0.publishedAt != nil }
      if drafts.isEmpty && published.isEmpty {
        ContentUnavailableView {
          Label("Seu próximo encontro começa aqui", systemImage: "calendar.badge.plus")
        } description: {
          Text("Crie um rascunho e complete os detalhes antes de publicar para a comunidade.")
        } actions: {
          Button("Criar evento") { editor = EditorRoute(record: nil) }
        }
      } else {
        if !drafts.isEmpty {
          Section("Rascunhos") { eventRows(drafts) }
        }
        if !published.isEmpty {
          Section("Publicados") { eventRows(published) }
        }
      }
    }
    .refreshable { await refresh() }
  }

  @ViewBuilder
  private func eventRows(_ events: [OrganizerEventRecord]) -> some View {
    ForEach(events) { event in
      Button {
        editor = EditorRoute(record: event)
      } label: {
        HStack(spacing: 14) {
          OrganizerEventDateBadge(draft: event.draft)
          VStack(alignment: .leading, spacing: 5) {
            Text(OrganizerDashboardData.title(for: event)).font(.headline).foregroundStyle(.primary)
            Text(access?.chapters.first { $0.id == event.draft.chapterID }?.name ?? "Capítulo")
              .font(.subheadline).foregroundStyle(.secondary)
            Text(OrganizerDashboardData.dateLine(for: event.draft))
              .font(.caption).foregroundStyle(.secondary)
            if event.publishedAt != nil, OrganizerDashboardData.hasUnpublishedChanges(event) {
              Text("Alterações ainda não publicadas").font(.caption).foregroundStyle(MataTheme.accent)
            }
          }
          Spacer(minLength: 8)
          Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
  }

  private func install(_ updated: OrganizerEventRecord) {
    records.removeAll { $0.id == updated.id }
    records.append(updated)
  }

  private func refresh() async {
    guard !isLoading, let userID = services.session.user?.id else { return }
    isLoading = true
    defer { isLoading = false }
    do {
      let currentAccess = try await services.organizer.access()
      try Task.checkCancellation()
      guard services.session.user?.id == currentAccess.user.id else { return }
      let choosesInitialChapter = access == nil && chapterID.isEmpty
      services.session.user = currentAccess.user
      access = currentAccess
      errorMessage = nil
      guard canOrganize else {
        records = []
        return
      }
      let chapters = Set(currentAccess.chapters.map(\.id))
      records = records.filter { chapters.contains($0.draft.chapterID) }
      if choosesInitialChapter || (!chapterID.isEmpty && !chapters.contains(chapterID)) {
        chapterID = currentAccess.chapters.first?.id ?? ""
      }
      let updated = try await services.organizer.events()
      try Task.checkCancellation()
      guard services.session.user?.id == currentAccess.user.id else { return }
      records = updated.filter { chapters.contains($0.draft.chapterID) }
    } catch is CancellationError {
      return
    } catch {
      guard services.session.user?.id == userID else { return }
      if OrganizerPresentationError.requiresSignIn(error) {
        services.session.errorMessage = "Sua sessão terminou. Entre novamente para continuar."
        await services.session.revoked()
        onClose()
      } else {
        errorMessage = OrganizerPresentationError.message(for: error)
        if (error as? AccountError)?.statusCode == 403 {
          access = nil
          records = []
        }
      }
    }
  }
}

enum OrganizerPresentationError {
  static func requiresSignIn(_ error: any Error) -> Bool {
    guard let error = error as? AccountError else { return false }
    return error == .authenticationRequired || error == .refreshUncertain || error.statusCode == 401
  }

  static func message(for error: any Error) -> String {
    if let validation = error as? OrganizerValidationError { return validation.reason }
    if let account = error as? AccountError {
      switch account.statusCode {
      case 403:
        return "Sua conta não tem acesso a esta ação ou a este capítulo. Atualize seu acesso na conta."
      case 409:
        return
          "Este evento foi alterado por outra pessoa ou janela. Feche o editor e atualize a lista antes de continuar."
      default: return account.localizedDescription
      }
    }
    if error is URLError {
      return
        "Não foi possível confirmar a solicitação. Confira sua conexão e atualize a lista antes de tentar novamente."
    }
    return "Não foi possível concluir esta ação. Atualize a lista e tente novamente."
  }
}
