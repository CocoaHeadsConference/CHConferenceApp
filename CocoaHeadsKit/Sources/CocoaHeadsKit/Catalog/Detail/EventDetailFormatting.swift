//
//  EventDetailFormatting.swift
//  CocoaHeadsKit
//
//  Formatting helpers for the catalog event detail screen.
//  Every date string uses the pt-BR locale and the event's own time zone.
//

import CocoaHeadsCore
import Foundation

enum EventDetailFormatting {
  static let locale = Locale(identifier: "pt_BR")

  /// Readable column width for the detail content on wide layouts.
  static let readableWidth: CGFloat = 760

  // MARK: Calendar

  static func calendar(for event: CommunityEvent) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = event.timeZone
    calendar.locale = locale
    return calendar
  }

  private static func style(for event: CommunityEvent) -> Date.FormatStyle {
    Date.FormatStyle(
      locale: locale,
      calendar: calendar(for: event),
      timeZone: event.timeZone
    )
  }

  private static func isSingleDay(_ event: CommunityEvent) -> Bool {
    calendar(for: event).isDate(event.startDate, inSameDayAs: event.endDate ?? event.startDate)
  }

  private static func isCurrentYear(_ event: CommunityEvent, now: Date) -> Bool {
    let calendar = calendar(for: event)
    return calendar.component(.year, from: event.startDate) == calendar.component(.year, from: now)
      && calendar.component(.year, from: event.endDate ?? event.startDate) == calendar.component(.year, from: now)
  }

  // MARK: Date and time lines

  /// "sábado, 12 de julho" or "12 – 13 de julho" / "30 de junho – 1 de julho".
  static func dateLine(for event: CommunityEvent, now: Date = .now) -> String {
    let base = style(for: event)
    let showYear = !isCurrentYear(event, now: now)

    if isSingleDay(event) {
      var single = base.weekday(.wide).day().month(.wide)
      if showYear { single = single.year() }
      return event.startDate.formatted(single)
    }

    let calendar = calendar(for: event)
    let endDate = event.endDate ?? event.startDate
    let sameMonth = calendar.isDate(event.startDate, equalTo: endDate, toGranularity: .month)
    var endStyle = base.day().month(.wide)
    if showYear { endStyle = endStyle.year() }
    let end = endDate.formatted(endStyle)

    if sameMonth {
      let start = event.startDate.formatted(base.day())
      return "\(start) – \(end)"
    }
    let start = event.startDate.formatted(base.day().month(.wide))
    return "\(start) – \(end)"
  }

  /// "19h00" in the event's time zone.
  static func clockTime(_ date: Date, for event: CommunityEvent) -> String {
    let components = calendar(for: event).dateComponents([.hour, .minute], from: date)
    return String(format: "%02dh%02d", components.hour ?? 0, components.minute ?? 0)
  }

  /// "19h00 – 22h00" for single-day events; start and end labelled for multi-day events.
  static func timeLine(for event: CommunityEvent) -> String {
    let start = clockTime(event.startDate, for: event)
    guard let endDate = event.endDate else { return "A partir das \(start)" }
    let end = clockTime(endDate, for: event)
    if isSingleDay(event) {
      return "\(start) – \(end)"
    }
    return "Início às \(start) · término às \(end)"
  }

  /// Spoken-friendly version used for accessibility labels ("19:00" reads as a time).
  static func accessibleTimeLine(for event: CommunityEvent) -> String {
    let base = style(for: event).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
    let start = event.startDate.formatted(base)
    guard let endDate = event.endDate else { return "a partir das \(start)" }
    let end = endDate.formatted(base)
    if isSingleDay(event) {
      return "das \(start) às \(end)"
    }
    return "início às \(start), término às \(end)"
  }

  /// Shown only when the event time zone differs from the device's, e.g. "Horário de Brasília".
  static func timeZoneNote(for event: CommunityEvent) -> String? {
    let eventOffset = event.timeZone.secondsFromGMT(for: event.startDate)
    let localOffset = TimeZone.current.secondsFromGMT(for: event.startDate)
    guard eventOffset != localOffset else { return nil }
    let name = event.timeZone.localizedName(for: .generic, locale: locale) ?? event.timezoneID
    return "Horário: \(name)"
  }

  // MARK: Phase

  static func phaseLabel(_ phase: EventPhase, for event: CommunityEvent) -> String {
    switch phase {
    case .upcoming:
      let relative = Date.RelativeFormatStyle(
        presentation: .named,
        unitsStyle: .wide,
        locale: locale,
        calendar: calendar(for: event)
      )
      return "Começa \(event.startDate.formatted(relative))"
    case .ongoing:
      return "Acontecendo agora"
    case .endedToday:
      return "Encerrado hoje"
    case .past:
      return "Evento encerrado"
    }
  }

  static func primaryActionTitle(for phase: EventPhase) -> String {
    switch phase {
    case .upcoming, .ongoing:
      return "Participar"
    case .endedToday, .past:
      return "Ver página do evento"
    }
  }

  // MARK: Format and hero caption

  static func formatLabel(_ format: EventFormat) -> String {
    switch format {
    case .inPerson: return "Presencial"
    case .online: return "Online"
    case .hybrid: return "Híbrido"
    }
  }

  static func heroCaption(for event: CommunityEvent, chapter: ChapterSummary?) -> String {
    let parts = [event.edition, chapter?.name].compactMap { $0 }
    if parts.isEmpty { return formatLabel(event.format) }
    return parts.joined(separator: " · ")
  }

  // MARK: Location

  /// Apple Maps universal link. Prefers coordinates, falls back to the address.
  static func mapsURL(for venue: EventVenue) -> URL? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "maps.apple.com"
    components.path = "/"

    var items = [URLQueryItem(name: "q", value: venue.name)]
    if let latitude = venue.latitude, let longitude = venue.longitude {
      items.append(URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"))
    } else {
      items.append(URLQueryItem(name: "address", value: venue.address))
    }
    components.queryItems = items
    return components.url
  }

  // MARK: Speakers

  /// Up to two initials, first and last name, used when there is no portrait.
  static func initials(for name: String) -> String {
    let words =
      name
      .split(whereSeparator: { $0.isWhitespace })
      .map(String.init)
      .filter { !$0.isEmpty }
    guard let first = words.first?.first else { return "?" }
    if words.count > 1, let last = words.last?.first {
      return String([first, last]).uppercased()
    }
    return String(first).uppercased()
  }
}
