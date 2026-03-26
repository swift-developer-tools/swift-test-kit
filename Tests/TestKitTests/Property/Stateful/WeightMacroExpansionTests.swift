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



internal final class WeightMacroExpansionTests: TestKitCase
{
    private static let macroSpecs: [String : MacroSpec] =
    [
        "Weight": MacroSpec(
            type:           TestKitMacros.WeightMacro.self,
            conformances:   ["Weight"]
        )
    ]
    
    
    
    func testExpansionOnStruct()
    {
        let structSource: String =
        """
        struct SomeStruct { }
        """
        
        let originalSource: String =
        """
        @Weight(1)
        \(structSource)
        """
        
        let message: String = WeightDiagnosticKind
            .requiresEnumCase
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
    
    
    
    func testExpansionWithNoArgument()
    {
        let originalSource: String =
        """
        enum SomeEnum
        {
            @Weight case a
            @Weight(1) case b
            @Weight(2) case c
        }
        """
        
        let expandedSource: String =
        """
        enum SomeEnum
        {
            case a
            case b
            case c
        }
        """
        
        let message: String = WeightDiagnosticKind
            .requiresArgument
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       3,
            column:     5
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     expandedSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
    
    
    
    func testExpansionWithNonIntegerLiteral()
    {
        let originalSource: String =
        """
        enum SomeEnum
        {
            let w: Int = 1
        
            @Weight(w) case a
            @Weight(1) case b
            @Weight(2) case c
        }
        """
        
        let expandedSource: String =
        """
        enum SomeEnum
        {
            let w: Int = 1
        
            case a
            case b
            case c
        }
        """
        
        let message: String = WeightDiagnosticKind
            .requiresIntegerLiteral
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       5,
            column:     5
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     expandedSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
    
    
    
    func testExpansionWithZeroWeight()
    {
        let originalSource: String =
        """
        enum SomeEnum
        {
            @Weight(0) case a
            @Weight(1) case b
            @Weight(2) case c
        }
        """
        
        let expandedSource: String =
        """
        enum SomeEnum
        {
            case a
            case b
            case c
        }
        """
        
        let message: String = WeightDiagnosticKind
            .requiresPositiveInteger
            .message
        
        let diagnostic = DiagnosticSpec(
            message:    message,
            line:       3,
            column:     5
        )
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     expandedSource,
            diagnostics:        [diagnostic],
            macroSpecs:         Self.macroSpecs
        )
    }
}
