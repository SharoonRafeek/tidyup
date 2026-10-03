// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TidyUp",
    platforms: [
        .macOS("26.0"),
    ],
    products: [
        .executable(name: "TidyUp", targets: ["TidyUp"]),
    ],
    targets: [
        .executableTarget(name: "TidyUp"),
        .testTarget(name: "TidyUpTests", dependencies: ["TidyUp"]),
    ]
)
