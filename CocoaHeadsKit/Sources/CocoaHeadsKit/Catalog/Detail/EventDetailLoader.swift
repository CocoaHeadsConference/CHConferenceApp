//
//  EventDetailLoader.swift
//  CocoaHeadsKit
//
//  Keeps the detail screen on the content it was opened with, then upgrades it
//  from the cache and the network. Ordinary failures keep the current content
//  and surface an unobtrusive retry; an unsupported screen replaces the UI.
//

import CocoaHeadsCore
import CocoaHeadsNetworking
import Foundation
import Observation

@MainActor
@Observable
final class EventDetailLoader {
  private(set) var event: CommunityEvent
  private(set) var isUnsupported = false
  private(set) var showsRefreshNotice = false
  private(set) var isRefreshing = false
  /// When the content currently on screen was fetched, if it came from the repository.
  private(set) var lastUpdated: Date?

  private var hasStarted = false

  init(event: CommunityEvent) {
    self.event = event
  }

  /// First load: cached copy (if any) followed by a network refresh. Safe to call repeatedly.
  func load(using repository: EventRepository) async {
    guard !hasStarted else { return }
    hasStarted = true
    defer {
      if Task.isCancelled { hasStarted = false }
    }

    if let cached = await repository.cachedEvent(id: event.id), !Task.isCancelled {
      apply(cached)
    }
    guard !Task.isCancelled else { return }
    await refresh(using: repository)
  }

  func refresh(using repository: EventRepository) async {
    guard !isRefreshing, !isUnsupported else { return }
    isRefreshing = true
    defer { isRefreshing = false }

    do {
      let snapshot = try await repository.event(id: event.id)
      guard apply(snapshot) else {
        // Payload belongs to another event; keep what we have and offer a retry.
        showsRefreshNotice = true
        return
      }
      showsRefreshNotice = snapshot.isStale
    } catch ScreenLoadingError.unsupportedScreen {
      isUnsupported = true
    } catch is CancellationError {
      // The owning view went away; nothing to report.
    } catch {
      showsRefreshNotice = true
    }
  }

  @discardableResult
  private func apply(_ snapshot: ScreenSnapshot<CommunityEvent>) -> Bool {
    guard snapshot.content.id == event.id else { return false }
    event = snapshot.content
    lastUpdated = snapshot.cachedAt
    return true
  }
}
