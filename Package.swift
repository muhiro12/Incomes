// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Incomes",
    platforms: [
        .iOS(.v17)
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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/muhiro12/GoogleMobileAdsWrapper.git", branch: "main"),
        .package(url: "https://github.com/muhiro12/LicenseListWrapper.git", branch: "main"),
        .package(url: "https://github.com/muhiro12/StoreKitWrapper.git", branch: "main"),
        .package(url: "https://github.com/muhiro12/SwiftUtilities.git", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "IncomesPlaygrounds",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "GoogleMobileAdsWrapper", package: "GoogleMobileAdsWrapper"),
                .product(name: "LicenseListWrapper", package: "LicenseListWrapper"),
                .product(name: "StoreKitWrapper", package: "StoreKitWrapper"),
                .product(name: "SwiftUtilities", package: "SwiftUtilities")
            ],
            path: "Incomes.swiftpm",
            exclude: [
                "IncomesPlaygroundsApp.swift",
                "Package.swift"
            ],
            resources: [
                .process("Resources")
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
