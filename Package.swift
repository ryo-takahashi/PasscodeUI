// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PasscodeUI",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "PasscodeUI",
            targets: ["PasscodeUI"]
        ),
    ],
    targets: [
        .target(
            name: "PasscodeUI",
            dependencies: [],
        ),
    ],
    swiftLanguageVersions: [.v5]
)
