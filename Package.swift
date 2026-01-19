// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "UITestToolkit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        // Library for Xcode UI test targets - screenshots
        .library(
            name: "ScreenshotKit",
            targets: ["ScreenshotKit"]
        ),
        // Library for Xcode UI test targets - common utilities
        .library(
            name: "UITestKit",
            targets: ["UITestKit"]
        ),
        // CLI tool to extract screenshots from xcresult
        .executable(
            name: "extract-screenshots",
            targets: ["ExtractScreenshots"]
        )
    ],
    targets: [
        .target(
            name: "ScreenshotKit",
            dependencies: []
        ),
        .target(
            name: "UITestKit",
            dependencies: []
        ),
        .executableTarget(
            name: "ExtractScreenshots",
            dependencies: []
        )
    ]
)
