// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let puddles = Target.Dependency.product(
  name: "Puddles",
  package: "Puddles")

let package = Package(
    name: "NSBrazilLib",
    platforms: [
      .iOS(.v17),
      .tvOS(.v17),
      .macOS(.v14),
      .visionOS(.v1),
      .watchOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NSBrazilLib",
            targets: ["NSBrazilLib"]),
    ],
    dependencies: [
      .package(
        url: "https://github.com/SwiftedMind/Puddles",
        from: Version(2, 0, 0)),
      .package(path: "Common"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NSBrazilLib",
            dependencies: [
              "Common",
              puddles
            ],
            resources: [
              .process("2019.json")
            ]),
        .testTarget(
            name: "NSBrazilLibTests",
            dependencies: ["NSBrazilLib"]),
    ]
)
