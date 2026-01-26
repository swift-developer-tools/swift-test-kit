// swift-tools-version: 6.1

import PackageDescription
import CompilerPluginSupport



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
        ),
        
        .package(
            url:    "https://github.com/swiftlang/swift-syntax",
            from:   "602.0.0"
        )
    ],
    targets:
    [
        .macro(
            name: "XCTestKitMacros",
            dependencies:
            [
                .product(
                    name:       "SwiftSyntax",
                    package:    "swift-syntax"
                ),
                
                .product(
                    name:       "SwiftSyntaxMacros",
                    package:    "swift-syntax"
                ),
                
                .product(
                    name:       "SwiftCompilerPlugin",
                    package:    "swift-syntax"
                )
            ]
        ),
        
        .target(
            name:           "XCTestKit",
            dependencies:   ["XCTestKitMacros"]
        ),
        
        .target(
            name:           "XCTestKitTestUtilities",
            dependencies:   ["XCTestKit"],
            path:           "Tests/Utilities"
        ),
        
        .testTarget(
            name: "XCTestKitTests",
            dependencies:
            [
                "XCTestKit",
                "XCTestKitTestUtilities"
            ]
        )
    ]
)
