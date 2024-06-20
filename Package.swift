// swift-tools-version: 5.9

import PackageDescription

let globalSwiftSettings: [PackageDescription.SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
]

let package = Package(
    name: "MeshGenerator",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "MeshGenerator",
            targets: ["MeshGenerator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MeshGenerator",
            dependencies: [],
            swiftSettings: globalSwiftSettings
        ),
        .testTarget(
            name: "MeshGeneratorTests",
            dependencies: ["MeshGenerator"]
        ),
    ]
)
