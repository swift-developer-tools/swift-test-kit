// swift-tools-version: 6.1

import PackageDescription



let package = Package(
    name: "XCTestKit",
    platforms:
    [
        .iOS(.v18),
        .macCatalyst(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .visionOS(.v2),
        .watchOS(.v11)
    ],
    products:
    [
        .library(
            name:       "XCTestKit",
            targets:    ["XCTestKit"]
        )
    ],
    dependencies:
    [
        .package(
            url:        "https://github.com/swiftlang/swift-docc-plugin",
            branch:     "main"
        )
    ],
    targets:
    [
        .target(
            name: "XCTestKit"
        ),
        
        .testTarget(
            name:           "XCTestKitTests",
            dependencies:   ["XCTestKit"]
        )
    ]
)
