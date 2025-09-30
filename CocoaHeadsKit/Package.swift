// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CocoaHeadsKit",
  platforms: [
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "CocoaHeadsKit",
      targets: ["CocoaHeadsKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.8.7"),
    .package(path: "../Common"),
    .package(path: "../QAKit"),
    .package(path: "../CocoaHeadsCore")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CocoaHeadsKit",
      dependencies: [
        .product(name: "SwiftSoup", package: "SwiftSoup"),
        "CocoaHeadsCore",
        "Common",
        "QAKit"
      ]
    ),
    .testTarget(
      name: "CocoaHeadsKitTests",
      dependencies: ["CocoaHeadsKit"]
    )
  ]
)
