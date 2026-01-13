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
