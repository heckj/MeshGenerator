// swift-tools-version: 5.6

// This is a legacy Package.swift structure to continue to maintain
// support for Swift 5.7 toolchains
import PackageDescription

let package = Package(
    name: "MeshGenerator",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
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
            dependencies: []
        ),
        .testTarget(
            name: "MeshGeneratorTests",
            dependencies: ["MeshGenerator"]
        ),
    ]
)
