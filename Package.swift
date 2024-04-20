// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PasscodeUI",
    platforms: [
        .iOS(.v15)
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
            path: "PasscodeUI"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
