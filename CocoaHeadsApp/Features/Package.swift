// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Features",
  platforms: [.macOS(.v12), .iOS(.v16)],
  products: [
    .library(
      name: "App",
      targets: ["App"]
    ),

    .library(
      name: "Counter",
      targets: ["Counter"]
    ),
  ],
  dependencies: [
    .package(path: "../Common"),
    .package(path: "../NetworkPlatform"),
    .package(path: "../PersistentPlatform"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      exact: "1.8.0"
    ),
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        "Counter",
        .product(name: "Common", package: "Common"),
        .product(name: "NetworkPlatform", package: "NetworkPlatform"),
        .product(name: "PersistentPlatform", package: "PersistentPlatform"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"),
      ]
    ),

    .target(
      name: "Counter",
      dependencies: [
        .product(name: "Common", package: "Common"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"),
      ]
    ),
  ]
)
