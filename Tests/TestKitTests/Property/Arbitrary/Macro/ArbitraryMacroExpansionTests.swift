//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitMacros
@testable import TestKitMacroCore
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosTestSupport



internal final class ArbitraryMacroExpansionTests: TestKitCase
{
    private static let macroSpecs: [String : MacroSpec] =
    [
        "Arbitrary": MacroSpec(
            type:           TestKitMacros.ArbitraryMacro.self,
            conformances:   ["Arbitrary"]
        )
    ]
    
    
    
    func testExpansionOnClass()
    {
        let classSource: String =
        """
        class SomeClass
        {
            var x: Int = 0
        }
        """
        
        let originalSource: String =
        """
        @Arbitrary
        \(classSource)
        """
        
        let message: String = ArbitraryDiagnosticKind
            .classNotSupported
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       1,
            column:     1
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     classSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
    
    
    
    func testExpansionOnUninhabitedEnum()
    {
        let enumSource: String =
        """
        enum SomeEnum { }
        """
        
        let originalSource: String =
        """
        @Arbitrary
        \(enumSource)
        """
        
        let message: String = ArbitraryDiagnosticKind
            .uninhabitedEnum
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       1,
            column:     1
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     enumSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
    
    
    
    func testExpansionOnStructWithMissingTypeAnnotation()
    {
        let structSource: String =
        """
        struct SomeStruct
        {
            var x = 0
        }
        """
        
        let originalSource: String =
        """
        @Arbitrary
        \(structSource)
        """
        
        let message: String = ArbitraryDiagnosticKind
            .missingTypeAnnotation(typeName: "x")
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       1,
            column:     1
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     structSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
    
    
    
    func testExpansionOnStructWithExplicitInit()
    {
        let structSource: String =
        """
        struct SomeStruct
        {
            var x: Int
        
            init(x: Int) { self.x = x }
        }
        """
        
        let originalSource: String =
        """
        @Arbitrary
        \(structSource)
        """
        
        let message: String = ArbitraryDiagnosticKind
            .structHasExplicitInit
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       1,
            column:     1
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     structSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
    
    
    
    func testExpansionOnActor()
    {
        let actorSource: String =
        """
        actor SomeActor
        {
            var x: Int = 0
        }
        """
        
        let originalSource: String =
        """
        @Arbitrary
        \(actorSource)
        """
        
        let message: String = ArbitraryDiagnosticKind
            .unsupportedDeclaration
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       1,
            column:     1
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     actorSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
}
