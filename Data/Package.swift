// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Data",
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
