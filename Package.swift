// swift-tools-version: 5.5

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

// Add the documentation compiler plugin if possible
#if swift(>=5.6)
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    )
#endif
