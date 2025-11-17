// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "Shared", package: "Shared")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: [
                "Presentation",
                .product(name: "Domain", package: "Domain"),
                .product(name: "Shared", package: "Shared")
            ]
        )
    ]
)
