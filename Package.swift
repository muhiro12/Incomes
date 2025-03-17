// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Incomes",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Incomes",
            targets: [
                "IncomesPlaygrounds"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/muhiro12/GoogleMobileAdsWrapper.git", branch: "main"),
        .package(url: "https://github.com/muhiro12/LicenseListWrapper.git", branch: "main"),
        .package(url: "https://github.com/muhiro12/StoreKitWrapper.git", branch: "main"),
        .package(url: "https://github.com/muhiro12/SwiftUtilities.git", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "IncomesPlaygrounds",
            dependencies: [
                .product(name: "GoogleMobileAdsWrapper", package: "GoogleMobileAdsWrapper"),
                .product(name: "LicenseListWrapper", package: "LicenseListWrapper"),
                .product(name: "StoreKitWrapper", package: "StoreKitWrapper"),
                .product(name: "SwiftUtilities", package: "SwiftUtilities")
            ],
            path: ".",
            exclude: [
                "Incomes"
            ],
            sources: [
                "Sources",
                "Incomes.swiftpm/Sources"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .define("XCODE")
            ]
        ),
        .testTarget(
            name: "IncomesPlaygroundsTests",
            dependencies: [
                "IncomesPlaygrounds"
            ],
            path: "Incomes/Tests"
        )
    ]
)
