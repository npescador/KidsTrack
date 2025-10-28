// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Shared",
    products: [
        .library(
            name: "Shared",
            targets: ["Shared"]
        ),
    ],
    targets: [
        .target(
            name: "Shared"
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),
    ]
)
