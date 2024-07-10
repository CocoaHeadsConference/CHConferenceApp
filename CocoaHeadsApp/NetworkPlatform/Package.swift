// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NetworkPlatform",
  platforms: [.macOS(.v12), .iOS(.v16)],
  products: [
    .library(
      name: "NetworkPlatform",
      targets: ["NetworkPlatform"])
  ],

  dependencies: [
    .package(path: "../Domain"),
    .package(path: "../Utilities"),
    .package(
      url: "https://github.com/Moya/Moya.git",
      from: "15.0.3"
    ),
  ],

  targets: [
    .target(
      name: "BuildConfiguration",
      dependencies: []),

    .target(
      name: "NetworkPlatform",
      dependencies: [
        "BuildConfiguration",
        .product(name: "Domain", package: "Domain"),
        .product(name: "Utilities", package: "Utilities"),
        .product(name: "Moya", package: "Moya"),
        .product(name: "CombineMoya", package: "Moya"),
      ],
      resources: [
        .copy("Resources/StubbedResponse/Product.json")
      ]
    ),
  ]
)
