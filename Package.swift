// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Tidy",
    platforms: [
        .macOS("26.0"),
    ],
    products: [
        .executable(name: "Tidy", targets: ["Tidy"]),
    ],
    targets: [
        .executableTarget(name: "Tidy"),
        .testTarget(name: "TidyTests", dependencies: ["Tidy"]),
    ]
)
