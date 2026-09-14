import CocoaHeadsCore
import SwiftUI

@MainActor
struct OrganizerEventEditor: View {
  @Environment(CocoaHeadsAppServices.self) private var services
  @Environment(\.dismiss) private var dismiss
  @State private var record: OrganizerEventRecord?
  @State private var fields: EditorFields
  @State private var savedFields: EditorFields
  @State private var isWorking = false
  @State private var errorMessage: String?
  @State private var successMessage: String?
  @State private var confirmsDiscard = false
  @State private var confirmsPublish = false
  @State private var publicationDraft: OrganizerEventDraft?

  private let chapters: [ChapterSummary]
  private let onSave: @MainActor (OrganizerEventRecord) -> Void

  init(
    record: OrganizerEventRecord? = nil, chapters: [ChapterSummary], initialChapterID: String? = nil,
    onSave: @escaping @MainActor (OrganizerEventRecord) -> Void
  ) {
    var draft = record?.draft ?? OrganizerEventDraft()
    if draft.chapterID.isEmpty { draft.chapterID = initialChapterID ?? chapters.first?.id ?? "" }
    let fields = EditorFields(draft: draft)
    _record = State(initialValue: record)
    _fields = State(initialValue: fields)
    _savedFields = State(initialValue: fields)
    self.chapters = chapters
    self.onSave = onSave
  }

  private var isDirty: Bool { fields != savedFields }
  private var canEdit: Bool {
    services.session.user?.role == .organizer || services.session.user?.role == .admin
  }
  private var chapterName: String {
    chapters.first { $0.id == (publicationDraft?.chapterID ?? fields.draft.chapterID) }?.name
      ?? "o capítulo selecionado"
  }

  var body: some View {
    Form {
      if services.session.user != nil {
        if canEdit {
          eventSection
          dateSection
          descriptionSection
          attendanceSection
          artworkSection
          feedbackSection
          actionsSection
        } else {
          Section {
            Text("Seu acesso à organização mudou. Volte à conta para conferir suas permissões.")
          }
        }
      }
    }
    .navigationTitle(record == nil ? "Criar evento" : "Editar evento")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Concluir") { requestDismiss() }
          .keyboardShortcut(.cancelAction)
          .disabled(isWorking)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Salvar") { Task { await save(publishing: false) } }
          .keyboardShortcut("s", modifiers: .command)
          .disabled(isWorking || chapters.isEmpty || !canEdit)
      }
    }
    .disabled(isWorking)
    .interactiveDismissDisabled(isDirty || isWorking)
    .alert("Descartar alterações?", isPresented: $confirmsDiscard) {
      Button("Continuar editando", role: .cancel) {}
      Button("Descartar", role: .destructive) { dismiss() }
    } message: {
      Text("As alterações que você ainda não salvou serão perdidas.")
    }
    .confirmationDialog(
      record?.publishedAt == nil ? "Publicar evento?" : "Publicar alterações?",
      isPresented: $confirmsPublish, titleVisibility: .visible
    ) {
      Button("Publicar em \(chapterName)") { Task { await save(publishing: true) } }
      Button("Cancelar", role: .cancel) { publicationDraft = nil }
    } message: {
      Text("Este evento ficará visível para toda a comunidade no capítulo \(chapterName).")
    }
    .onChange(of: services.session.user?.id) { _, userID in
      if userID == nil { dismiss() }
    }
    .onChange(of: fields) { _, updated in
      if updated != savedFields { successMessage = nil }
    }
  }

  private var eventSection: some View {
    Section("Evento") {
      TextField("Título", text: $fields.draft.title, axis: .vertical)
      Picker("Capítulo", selection: $fields.draft.chapterID) {
        if !chapters.contains(where: { $0.id == fields.draft.chapterID }) {
          Text("Escolha um capítulo").tag(fields.draft.chapterID)
        }
        ForEach(chapters) { chapter in Text(chapter.name).tag(chapter.id) }
      }
    }
  }

  private var dateSection: some View {
    Section {
      Toggle(
        "Definir início",
        isOn: Binding(
          get: { fields.draft.startDate != nil },
          set: { enabled in
            fields.draft.startDate = enabled ? .now : nil
            if !enabled { fields.draft.endDate = nil }
          }))
      if fields.draft.startDate != nil {
        DatePicker(
          "Início",
          selection: Binding(
            get: { fields.draft.startDate ?? .now }, set: { fields.draft.startDate = $0 }))
        Toggle(
          "Definir encerramento",
          isOn: Binding(
            get: { fields.draft.endDate != nil },
            set: { enabled in
              fields.draft.endDate = enabled ? (fields.draft.startDate ?? .now).addingTimeInterval(7_200) : nil
            }))
        if fields.draft.endDate != nil {
          DatePicker(
            "Encerramento",
            selection: Binding(
              get: { fields.draft.endDate ?? .now }, set: { fields.draft.endDate = $0 }))
        }
      }
      Picker("Fuso horário", selection: $fields.draft.timezoneID) {
        Text("Brasília").tag("America/Sao_Paulo")
        Text("Manaus").tag("America/Manaus")
        Text("Rio Branco").tag("America/Rio_Branco")
        Text("Fernando de Noronha").tag("America/Noronha")
        if !["America/Sao_Paulo", "America/Manaus", "America/Rio_Branco", "America/Noronha"].contains(
          fields.draft.timezoneID)
        {
          Text(fields.draft.timezoneID).tag(fields.draft.timezoneID)
        }
      }
    } header: {
      Text("Data e horário")
    } footer: {
      Text(
        "Os horários seguem o fuso escolhido. Sem encerramento, o encontro permanece em andamento até o fim desse dia.")
    }
    .environment(\.timeZone, TimeZone(identifier: fields.draft.timezoneID) ?? .current)
  }

  private var descriptionSection: some View {
    Section("Sobre o encontro") {
      TextField("Descrição", text: $fields.draft.summary, axis: .vertical)
        .lineLimit(4...12)
      TextField("Link de inscrição", text: $fields.draft.registrationURL)
        .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
    }
  }

  @ViewBuilder
  private var attendanceSection: some View {
    Section("Participação") {
      Picker("Formato", selection: $fields.draft.format) {
        Text("Presencial").tag(EventFormat.inPerson)
        Text("Online").tag(EventFormat.online)
        Text("Híbrido").tag(EventFormat.hybrid)
      }
      if fields.draft.format != .inPerson {
        TextField("Link da transmissão", text: $fields.onlineURL)
          .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
      }
    }
    if fields.draft.format != .online {
      Section("Local") {
        TextField("Nome do local", text: $fields.venueName)
        TextField("Endereço completo", text: $fields.venueAddress, axis: .vertical)
          .textContentType(.fullStreetAddress)
        TextField("Como chegar e entrar (opcional)", text: $fields.arrivalInstructions, axis: .vertical)
          .lineLimit(2...6)
        TextField("Latitude (opcional)", text: $fields.latitude)
          .keyboardType(.numbersAndPunctuation).autocorrectionDisabled()
        TextField("Longitude (opcional)", text: $fields.longitude)
          .keyboardType(.numbersAndPunctuation).autocorrectionDisabled()
      }
    }
  }

  private var artworkSection: some View {
    Section {
      TextField("Link da imagem (opcional)", text: $fields.imageURL)
        .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
    } header: {
      Text("Imagem do evento")
    } footer: {
      Text("Use o endereço público de uma imagem. Sem imagem, o app usa a identidade visual do CocoaHeads.")
    }
  }

  @ViewBuilder
  private var feedbackSection: some View {
    if let errorMessage {
      Section { Text(errorMessage).foregroundStyle(.red) }
    }
    if let successMessage {
      Section { Label(successMessage, systemImage: "checkmark.circle").foregroundStyle(MataTheme.accent) }
    }
    if isWorking {
      Section { ProgressView("Salvando…") }
    }
  }

  private var actionsSection: some View {
    Section {
      Button("Salvar rascunho") { Task { await save(publishing: false) } }
      Button(record?.publishedAt == nil ? "Publicar evento…" : "Publicar alterações…") {
        preparePublication()
      }
    } footer: {
      Text("Salvar mantém as alterações em rascunho. A comunidade só vê as mudanças depois que você publica.")
    }
    .disabled(chapters.isEmpty)
  }

  private func requestDismiss() {
    if isDirty { confirmsDiscard = true } else { dismiss() }
  }

  private func preparePublication() {
    do {
      let draft = try fields.makeDraft()
      _ = try draft.publishedEvent(id: record?.id ?? "new-event")
      publicationDraft = draft
      errorMessage = nil
      confirmsPublish = true
    } catch {
      errorMessage = OrganizerPresentationError.message(for: error)
      successMessage = nil
    }
  }

  private func save(publishing: Bool) async {
    guard !isWorking, canEdit, let userID = services.session.user?.id else { return }
    isWorking = true
    errorMessage = nil
    successMessage = nil
    defer {
      isWorking = false
      publicationDraft = nil
    }
    do {
      let draft: OrganizerEventDraft
      if publishing, let publicationDraft {
        draft = publicationDraft
      } else {
        draft = try fields.makeDraft()
      }
      try draft.validateForSaving()
      guard chapters.contains(where: { $0.id == draft.chapterID }) else {
        throw OrganizerValidationError(reason: "Escolha um dos capítulos disponíveis para sua conta.")
      }
      if publishing { _ = try draft.publishedEvent(id: record?.id ?? "new-event") }
      let saved = try await services.organizer.save(draft: draft, replacing: record)
      guard services.session.user?.id == userID else { return }
      // Keep the returned revision even if publication subsequently fails.
      install(saved)
      successMessage = "Rascunho salvo."
      if publishing {
        let published = try await services.organizer.publish(saved)
        guard services.session.user?.id == userID else { return }
        install(published)
        services.didPublish()
        successMessage = "Evento publicado."
      }
    } catch is CancellationError {
      return
    } catch {
      guard services.session.user?.id == userID else { return }
      if OrganizerPresentationError.requiresSignIn(error) {
        services.session.errorMessage = "Sua sessão terminou. Entre novamente para continuar."
        await services.session.revoked()
        dismiss()
      } else {
        errorMessage = OrganizerPresentationError.message(for: error)
      }
    }
  }

  private func install(_ updated: OrganizerEventRecord) {
    record = updated
    fields = EditorFields(draft: updated.draft)
    savedFields = fields
    onSave(updated)
  }
}

private struct EditorFields: Equatable {
  var draft: OrganizerEventDraft
  var venueName: String
  var venueAddress: String
  var arrivalInstructions: String
  var latitude: String
  var longitude: String
  var onlineURL: String
  var imageURL: String

  init(draft: OrganizerEventDraft) {
    self.draft = draft
    venueName = draft.venue?.name ?? ""
    venueAddress = draft.venue?.address ?? ""
    arrivalInstructions = draft.venue?.arrivalInstructions ?? ""
    latitude = draft.venue?.latitude.map { String($0) } ?? ""
    longitude = draft.venue?.longitude.map { String($0) } ?? ""
    onlineURL = draft.onlineURL?.absoluteString ?? ""
    imageURL = draft.imageURL?.absoluteString ?? ""
  }

  func makeDraft() throws -> OrganizerEventDraft {
    // Preserve every field this initial editor doesn't expose (talks, Q&A, links, etc.).
    var result = draft
    result.onlineURL = try optionalURL(onlineURL, field: "transmissão")
    result.imageURL = try optionalURL(imageURL, field: "imagem")
    let lat = try coordinate(latitude)
    let lon = try coordinate(longitude)
    let hasVenue =
      !venueName.isEmpty || !venueAddress.isEmpty || !arrivalInstructions.isEmpty || lat != nil || lon != nil
    result.venue =
      hasVenue
      ? EventVenue(
        name: venueName, address: venueAddress, latitude: lat, longitude: lon,
        arrivalInstructions: arrivalInstructions.isEmpty ? nil : arrivalInstructions) : nil
    return result
  }

  private func optionalURL(_ text: String, field: String) throws -> URL? {
    let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if value.isEmpty { return nil }
    guard let url = URL(string: value) else {
      throw OrganizerValidationError(reason: "Confira o link de \(field).")
    }
    return url
  }

  private func coordinate(_ text: String) throws -> Double? {
    let value = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
    if value.isEmpty { return nil }
    guard let coordinate = Double(value), coordinate.isFinite else {
      throw OrganizerValidationError(reason: "Informe as coordenadas como números, por exemplo -23,55.")
    }
    return coordinate
  }
}
