// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package( // swiftlint:disable:this prefixed_toplevel_constant
    name: "IncomesLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "IncomesLibrary",
            targets: ["IncomesLibrary"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/muhiro12/SwiftUtilities",
            "1.0.0"..<"1.35.0"
        ),
        .package(
            url: "https://github.com/muhiro12/MHPlatform.git",
            branch: "codex/shared-mutation-workflow"
        )
    ],
    targets: [
        .target(
            name: "IncomesLibrary",
            dependencies: [
                .product(
                    name: "SwiftUtilities",
                    package: "SwiftUtilities"
                ),
                .product(
                    name: "MHDeepLinking",
                    package: "MHPlatform"
                ),
                .product(
                    name: "MHPreferences",
                    package: "MHPlatform"
                ),
                .product(
                    name: "MHPersistenceMaintenance",
                    package: "MHPlatform"
                ),
                .product(
                    name: "MHNotificationPlans",
                    package: "MHPlatform"
                )
            ],
            path: ".",
            sources: [
                "Sources"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "IncomesLibraryTests",
            dependencies: ["IncomesLibrary"],
            path: "Tests/Default"
        ),
        .testTarget(
            name: "IncomesLibraryTimeZoneTests",
            dependencies: ["IncomesLibrary"],
            path: "Tests/TimeZone"
        )
    ]
)
