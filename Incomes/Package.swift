// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Incomes",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Incomes",
            targets: [
                "IncomesLibrary"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/muhiro12/GoogleMobileAdsWrapper.git", branch: "main"),
        .package(url: "https://github.com/cybozu/LicenseList.git", from: "0.0.0")
    ],
    targets: [
        .target(
            name: "IncomesLibrary",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "GoogleMobileAdsWrapper", package: "GoogleMobileAdsWrapper"),
                .product(name: "LicenseList", package: "LicenseList")
            ]
        ),
        .testTarget(
            name: "IncomesLibraryTests",
            dependencies: [
                "IncomesLibrary"
            ]
        )
    ]
)
