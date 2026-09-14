import AuthenticationServices
import CocoaHeadsNetworking
import Observation
import SwiftUI

/// Owned above WindowGroup so windows share refresh-token rotation and publishing state.
@MainActor @Observable
public final class CocoaHeadsAppServices {
  let repository: EventRepository
  let catalog: EventCatalogLoader
  let images: EventImageStore
  let session: AccountSession
  let organizer: OrganizerRepository
  var catalogRevision = 0

  public convenience init() {
    let configuration = EventClientConfiguration.applicationConfiguration()
    let key = Bundle.main.object(forInfoDictionaryKey: "CocoaHeadsAPIKey") as? String ?? ""
    self.init(configuration: configuration, apiKey: key)
  }

  public init(configuration: EventClientConfiguration, apiKey: String = "", persistMockEdits: Bool = true) {
    let mockStore: MockOrganizerStore?
    if configuration.environment == .mock {
      let url =
        persistMockEdits
        ? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
          .appending(path: "CocoaHeads/Mock/organizer.json") : nil
      mockStore = MockOrganizerStore(storageURL: url)
    } else {
      mockStore = nil
    }
    let repository = EventRepository(configuration: configuration, mockOrganizerStore: mockStore)
    self.repository = repository
    catalog = EventCatalogLoader(repository: repository)
    images = EventImageStore(configuration: configuration)
    let account = AccountClient(configuration: configuration, apiKey: apiKey)
    session = AccountSession(client: account)
    organizer = OrganizerRepository(account: account, mockStore: mockStore)
  }

  func didPublish() { catalogRevision += 1 }
}

private enum CatalogPreviewServices {
  static let repository = EventRepository(configuration: .init(environment: .mock))
  static let images = EventImageStore(configuration: .init(environment: .mock))
}

extension EnvironmentValues {
  // Previews are self-contained. The app entry explicitly injects the selected environment.
  @Entry var eventRepository = CatalogPreviewServices.repository
  @Entry var eventImageStore = CatalogPreviewServices.images
}

public struct CocoaHeadsAppView: View {
  @Environment(\.scenePhase) private var scenePhase
  @State private var services: CocoaHeadsAppServices
  @State private var selectedTab = AppTab.events
  @State private var showsOrganization = false
  @State private var searchText = ""
  @State private var isSearching = false

  private enum AppTab: Hashable { case events, profile, search, organization }

  private var searchTabRole: TabRole {
    if #available(iOS 27.0, macCatalyst 27.0, visionOS 27.0, *) {
      return .prominent
    }
    return .search
  }

  public init() {
    self.init(services: CocoaHeadsAppServices())
  }

  public init(configuration: EventClientConfiguration) {
    _services = State(initialValue: CocoaHeadsAppServices(configuration: configuration))
  }

  public init(services: CocoaHeadsAppServices) {
    _services = State(initialValue: services)
  }

  public var body: some View {
    // Keep this container alive so Catalyst can replace its window tabs when switching workspaces.
    TabView(selection: $selectedTab) {
      if showsOrganization {
        Tab("Organização", systemImage: "square.grid.2x2", value: AppTab.organization) {
          OrganizerHomeView {
            selectedTab = .profile
            showsOrganization = false
          }
          .toolbarVisibility(.hidden, for: .tabBar)
        }
      } else {
        Tab("Eventos", systemImage: "calendar", value: AppTab.events) {
          EventsHomeView()
        }
        Tab("Perfil", systemImage: "person.crop.circle", value: AppTab.profile) {
          AccountView {
            showsOrganization = true
            selectedTab = .organization
          }
        }
        Tab("Buscar", systemImage: "magnifyingglass", value: AppTab.search, role: searchTabRole) {
          EventsHomeView(searchText: $searchText)
            .searchable(
              text: $searchText, isPresented: $isSearching,
              prompt: "Buscar eventos, capítulos e palestras")
        }
      }
    }
    .environment(\.eventRepository, services.repository)
    .environment(\.eventImageStore, services.images)
    .environment(services)
    .tint(MataTheme.accent)
    .task { await services.session.restore() }
    .onChange(of: selectedTab) { _, tab in
      isSearching = tab == .search
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active { Task { await services.session.refresh() } }
    }
    .onReceive(
      NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)
    ) { _ in
      Task { await services.session.revoked() }
    }
    .onChange(of: services.session.user?.role) { _, role in
      if showsOrganization, role != .organizer && role != .admin {
        selectedTab = .profile
        showsOrganization = false
      }
    }
  }
}

extension EventClientConfiguration {
  /// Build settings select the environment; debug launch overrides support device development.
  static func applicationConfiguration(
    bundle: Bundle = .main,
    processEnvironment: [String: String] = ProcessInfo.processInfo.environment
  ) -> Self {
    let environment: CatalogEnvironment
    var scenario = MockScenario.standard
    var baseURLString = bundle.object(forInfoDictionaryKey: "CocoaHeadsAPIBaseURL") as? String ?? ""
    #if DEBUG
      let configured = bundle.object(forInfoDictionaryKey: "CocoaHeadsEnvironment") as? String ?? "production"
      environment = CatalogEnvironment(rawValue: configured) ?? .production
      if let override = processEnvironment["COCOAHEADS_API_URL"] { baseURLString = override }
      if let name = processEnvironment["COCOAHEADS_MOCK_SCENARIO"], let value = MockScenario(rawValue: name) {
        scenario = value
      }
    #else
      environment = .production
    #endif
    let trimmed = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
    let url = URL(string: trimmed).flatMap { value in
      ["http", "https"].contains(value.scheme?.lowercased() ?? "") && value.host != nil ? value : nil
    }
    return .init(environment: environment, baseURL: url, scenario: scenario)
  }
}

#Preview {
  CocoaHeadsAppView(configuration: .init(environment: .mock, baseURL: nil))
}
