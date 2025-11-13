// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]
        ),
    ],
    targets: [
        .target(
            name: "Data"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]
        ),
    ]
)
