// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "lunaris",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Lunaris",
            targets: ["Lunaris"])
    ],
    dependencies: [
        .package(path: "../orbiverse")
//        .package(url: "https://github.com/Corbin-Bigler/orbiverse.git", branch: "main" )
    ],
    targets: [
        .target(
            name: "Lunaris",
            dependencies: [
                .product(name: "Orbiverse", package: "orbiverse"),
            ]
        ),
    ]
)
