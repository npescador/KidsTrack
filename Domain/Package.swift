// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]
        )
    ],
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Shared", package: "Shared")
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                .product(name: "Shared", package: "Shared")
            ]
        )
    ]
)
