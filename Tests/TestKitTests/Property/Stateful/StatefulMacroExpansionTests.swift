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



internal final class StatefulMacroExpansionTests: TestKitCase
{
    private static let macroSpecs: [String : MacroSpec] =
    [
        "Stateful": MacroSpec(
            type:           TestKitMacros.StatefulMacro.self,
            conformances:   ["Stateful"]
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
        @Stateful
        \(classSource)
        """
        
        let message: String = StatefulDiagnosticKind
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
    
    
    
    func testExpansionOnStruct()
    {
        let structSource: String =
        """
        struct SomeStruct
        {
            var x: Int = 0
        }
        """
        
        let originalSource: String =
        """
        @Stateful
        \(structSource)
        """
        
        let message: String = StatefulDiagnosticKind
            .structNotSupported
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
    
    
    
    func testExpansionOnUninhabitedEnum()
    {
        let enumSource: String =
        """
        enum SomeEnum { }
        """
        
        let originalSource: String =
        """
        @Stateful
        \(enumSource)
        """
        
        let message: String = StatefulDiagnosticKind
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
        @Stateful
        \(actorSource)
        """
        
        let message: String = StatefulDiagnosticKind
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
