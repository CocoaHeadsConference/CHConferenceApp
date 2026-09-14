import Foundation

/// Accessed only inside the owning repository/image-store actor.
struct PersistentCache: Sendable {
  struct Entry: Codable, Sendable {
    let key: String
    let data: Data
    let cachedAt: Date
  }

  private let namespace: String
  private let directory: URL
  private var memory: [String: Entry] = [:]

  init(configuration: EventClientConfiguration, category: String, directory: URL?) {
    namespace = configuration.cacheNamespace + "/" + category
    let root =
      directory ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
      ?? FileManager.default.temporaryDirectory
    self.directory = root.appending(path: "CocoaHeadsNetworking/v1")
      .appending(path: configuration.environment.rawValue)
      .appending(path: Self.fileName(configuration.cacheNamespace))
      .appending(path: category)
  }

  mutating func read(key: String) -> Entry? {
    if let entry = memory[key] { return entry }
    guard let data = try? Data(contentsOf: fileURL(key: key)),
      let entry = try? JSONDecoder().decode(Entry.self, from: data),
      entry.key == namespace + "/" + key
    else { return nil }
    remember(entry, key: key)
    return entry
  }

  mutating func write(_ data: Data, key: String, at date: Date) {
    let entry = Entry(key: namespace + "/" + key, data: data, cachedAt: date)
    remember(entry, key: key)
    // Disk pressure/permissions must not turn a valid server response into a screen failure.
    do {
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try JSONEncoder().encode(entry).write(to: fileURL(key: key), options: .atomic)
    } catch {
      // The last valid response remains available for the lifetime of this actor.
    }
  }

  private func fileURL(key: String) -> URL {
    directory.appending(path: Self.fileName(key) + ".json")
  }

  private mutating func remember(_ entry: Entry, key: String) {
    memory[key] = entry
    let limit = 32 * 1_024 * 1_024
    var byteCount = memory.values.reduce(0) { $0 + $1.data.count }
    while byteCount > limit, let oldest = memory.min(by: { $0.value.cachedAt < $1.value.cachedAt }) {
      byteCount -= oldest.value.data.count
      memory.removeValue(forKey: oldest.key)
    }
  }

  private static func fileName(_ value: String) -> String {
    // Stable FNV-1a filenames; the full namespace/key inside every entry verifies collisions.
    // Unlike Swift.hashValue this survives launches, and URL/event IDs cannot escape the directory.
    var hash: UInt64 = 14_695_981_039_346_656_037
    for byte in value.utf8 {
      hash = (hash ^ UInt64(byte)) &* 1_099_511_628_211
    }
    return String(hash, radix: 16)
  }
}
