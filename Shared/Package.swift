// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Shared",
            targets: ["Shared"]
        )
    ],
    targets: [
        .target(
            name: "Shared"
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        )
    ]
)
