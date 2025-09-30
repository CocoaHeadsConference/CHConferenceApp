// swift-tools-version:6.2
import PackageDescription

let package = Package(
  name: "backend",
  platforms: [
    .macOS(.v26)
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
    // 🗄 An ORM for SQL and NoSQL databases.
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    // 🐘 Fluent driver for Postgres.
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
    // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.8.7"),
    .package(path: "../CocoaHeadsCore")
  ],
  targets: [
    .executableTarget(
      name: "backend",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "SwiftSoup", package: "SwiftSoup"),
        "CocoaHeadsCore"
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "backendTests",
      dependencies: [
        .target(name: "backend"),
        .product(name: "VaporTesting", package: "vapor")
      ],
      swiftSettings: swiftSettings
    )
  ]
)

var swiftSettings: [SwiftSetting] {
  [
    .enableUpcomingFeature("ExistentialAny")
  ]
}
