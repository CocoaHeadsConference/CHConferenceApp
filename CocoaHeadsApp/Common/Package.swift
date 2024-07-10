// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Common",
  platforms: [.macOS(.v12), .iOS(.v16)],
  products: [
    .library(
      name: "Common",
      targets: ["Common"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      exact: "1.8.0"
    )
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture")
      ]
    )
  ]
)
