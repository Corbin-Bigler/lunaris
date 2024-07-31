// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lunaris",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Lunaris",
            targets: ["Lunaris"]),
    ],
    targets: [
        .target(name: "Lunaris"),
        .testTarget(
            name: "LunarisTests",
            dependencies: ["Lunaris"]),
    ]
)
