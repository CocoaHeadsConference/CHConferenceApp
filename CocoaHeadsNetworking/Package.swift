// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "CocoaHeadsNetworking",
  platforms: [.iOS(.v26), .visionOS(.v26), .macOS(.v26)],
  products: [.library(name: "CocoaHeadsNetworking", targets: ["CocoaHeadsNetworking"])],
  dependencies: [.package(path: "../CocoaHeadsCore")],
  targets: [
    .target(
      name: "CocoaHeadsNetworking", dependencies: ["CocoaHeadsCore"],
      resources: [.process("Resources")]),
    .testTarget(name: "CocoaHeadsNetworkingTests", dependencies: ["CocoaHeadsNetworking"])
  ],
  swiftLanguageModes: [.v6]
)
