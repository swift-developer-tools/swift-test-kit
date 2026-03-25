// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport



let package = Package(
    name: "SwiftTestKit",
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
            name: "SwiftTestKit",
            targets: ["SwiftTestKit"]
        ),
        
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
            name: "ReasyncMacroCore",
            dependencies:
            [
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
            name: "ReasyncMacro",
            dependencies:
            [
                "ReasyncMacroCore",
                
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                )
            ]
        ),
        
        .target(
            name: "TestKitCore",
            dependencies: ["ReasyncMacro"]
        ),
        
        .target(
            name: "TestKitMacroCore",
            dependencies:
            [
                "TestKitCore",
                
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
            name: "TestKitMacros",
            dependencies:
            [
                "TestKitMacroCore",
                
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                )
            ]
        ),
        
        .target(
            name: "SwiftTestKit",
            dependencies:
            [
                "TestKitCore",
                "TestKitMacros"
            ]
        ),
        
        .target(
            name: "XCTestKit",
            dependencies:
            [
                "TestKitCore",
                "TestKitMacros"
            ]
        ),
        
        .testTarget(
            name: "TestKitTests",
            dependencies:
            [
                "ReasyncMacroCore",
                "TestKitCore",
                "TestKitMacroCore",
                "SwiftTestKit",
                "XCTestKit"
            ]
        )
    ]
)
