// swift-tools-version: 6.4

import PackageDescription

let package = Package( // swiftlint:disable:this prefixed_toplevel_constant
    name: "IncomesReleaseTools",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/muhiro12/Apogee.git", exact: "0.5.0")
    ]
)
