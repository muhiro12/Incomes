// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IncomesLibrary",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "IncomesLibrary",
            targets: ["IncomesLibrary"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/muhiro12/SwiftUtilities", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "IncomesLibrary",
            dependencies: [
                .product(name: "SwiftUtilities", package: "SwiftUtilities")
            ]
        ),
        .testTarget(
            name: "IncomesLibraryTests",
            dependencies: ["IncomesLibrary"]
        )
    ]
)
