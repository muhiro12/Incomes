// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Incomes Playgrounds",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Incomes Playgrounds",
            targets: ["AppModule"],
            bundleIdentifier: "com.muhiro12.Incomes.playgrounds",
            teamIdentifier: "66PKF55HK5",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/muhiro12/SwiftUtilities.git", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "SwiftUtilities", package: "SwiftUtilities")
            ],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
