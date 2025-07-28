// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "QAKit",
  platforms: [
    .iOS("18.2"),
    .visionOS("2.2"),
    .macOS("14.0")
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "QAKit",
      targets: ["QAKit"])
  ],
  dependencies: [
    .package(path: "../Common")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "QAKit",
      dependencies: [
        "Common"
      ]
    ),
    .testTarget(
      name: "QAKitTests",
      dependencies: ["QAKit"]
    )
  ]
)
