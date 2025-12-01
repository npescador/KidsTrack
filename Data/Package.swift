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
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Shared"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "Shared", package: "Shared"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data",
                .product(name: "Domain", package: "Domain"),
                .product(name: "Shared", package: "Shared")
            ]
        )
    ]
)
