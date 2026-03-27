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
            url: "https://github.com/swift-developer-tools/swift-reasync",
            branch: "main"
        ),
        
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            branch: "main"
        ),
        
        .package(
            url: "https://github.com/swiftlang/swift-syntax",
            from: "603.0.0"
        )
    ],
    targets:
    [
        .target(
            name: "TestKitCore",
            dependencies:
            [
                .product(
                    name: "Reasync",
                    package: "swift-reasync"
                )
            ]
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
                "TestKitMacros",
                
                .product(
                    name: "Reasync",
                    package: "swift-reasync"
                )
            ]
        ),
        
        .target(
            name: "XCTestKit",
            dependencies:
            [
                "TestKitCore",
                "TestKitMacros",
                
                .product(
                    name: "Reasync",
                    package: "swift-reasync"
                )
            ]
        ),
        
        .testTarget(
            name: "TestKitTests",
            dependencies:
            [
                "TestKitCore",
                "TestKitMacros",
                "TestKitMacroCore",
                "SwiftTestKit",
                "XCTestKit",
                
                .product(
                    name: "Reasync",
                    package: "swift-reasync"
                ),
                
                .product(
                    name: "SwiftSyntaxMacroExpansion",
                    package: "swift-syntax"
                ),
                
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                )
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
