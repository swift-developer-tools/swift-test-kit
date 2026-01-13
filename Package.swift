// swift-tools-version: 6.1

import PackageDescription



let package = Package(
    name: "XCTestKit",
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
