import CocoaHeadsCore
import CocoaHeadsNetworking
import Observation

/// The events and search tabs share one catalog, including in-flight loads and offline recovery.
@MainActor @Observable
final class EventCatalogLoader {
  private(set) var snapshot: ScreenSnapshot<EventCatalog>?
  private(set) var hasLoaded = false
  private(set) var isRefreshing = false
  private(set) var isUnsupported = false
  private(set) var refreshFailed = false

  private let repository: EventRepository
  @ObservationIgnored private var initialLoad: Task<Void, Never>?
  @ObservationIgnored private var refreshTask: Task<Void, Never>?

  var isLoading: Bool { snapshot == nil && (!hasLoaded || isRefreshing) }

  init(repository: EventRepository) {
    self.repository = repository
  }

  func load() async {
    guard !hasLoaded else { return }
    if let initialLoad {
      await initialLoad.value
      return
    }
    // The store owns this task so switching tabs doesn't cancel a load needed by the next tab.
    let task = Task {
      if let cached = await repository.cachedCatalog(), snapshot == nil { snapshot = cached }
      await refresh()
      hasLoaded = true
    }
    initialLoad = task
    await task.value
    initialLoad = nil
  }

  func refresh() async {
    if let refreshTask {
      await refreshTask.value
      return
    }
    isRefreshing = true
    let task = Task {
      defer { isRefreshing = false }
      do {
        snapshot = try await repository.catalog()
        isUnsupported = false
        refreshFailed = false
      } catch is CancellationError {
        return
      } catch ScreenLoadingError.unsupportedScreen {
        isUnsupported = true
      } catch {
        refreshFailed = snapshot != nil
      }
    }
    refreshTask = task
    await task.value
    refreshTask = nil
  }
}
