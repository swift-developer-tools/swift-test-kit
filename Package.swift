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
            name: "XCTestKit",
            targets: ["XCTestKit"]
        )
    ],
    dependencies:
    [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            branch: "main"
        ),
        
        .package(
            url: "https://github.com/swiftlang/swift-syntax",
            from: "602.0.0"
        )
    ],
    targets:
    [
        .target(
            name: "XCTestKitCore",
            dependencies: []
        ),
        
        .target(
            name: "TestKitMacros",
            dependencies:
            [
                "XCTestKitCore",
                
                .product(
                    name: "SwiftSyntax",
                    package: "swift-syntax"
                ),
                
                .product(
                    name: "SwiftSyntaxMacros",
                    package: "swift-syntax"
                )
            ]
        ),
        
        .macro(
            name: "XCTestKitMacros",
            dependencies:
            [
                "TestKitMacros",
                
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                )
            ]
        ),
        
        .target(
            name: "XCTestKit",
            dependencies:
            [
                "XCTestKitCore",
                "XCTestKitMacros"
            ]
        ),
        
        .target(
            name: "TKTestUtilities",
            dependencies: ["XCTestKit"],
            path: "Tests/TKTestUtilities"
        ),
        
        .testTarget(
            name: "XCTKTests",
            dependencies:
            [
                "XCTestKit",
                "TestKitMacros",
                "TKTestUtilities"
            ]
        )
    ]
)
