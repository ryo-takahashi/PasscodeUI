// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PasscodeUI",
    defaultLocalization: "en",
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
            path: "PasscodeUI/Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
