// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        ),
    ],
    targets: [
        .target(
            name: "Presentation"
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
    ]
)
