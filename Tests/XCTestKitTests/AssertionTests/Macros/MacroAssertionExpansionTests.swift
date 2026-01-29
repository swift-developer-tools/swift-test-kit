//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import XCTestKit
@testable import XCTestKitMacros
@testable import XCTestKitTestUtilities



internal final class MacroAssertionExpansionTests: XCTestKitCase
{
    private typealias AK = AssertionKind
    
    
    
    // MARK: - Boolean
    
    func testAssertExpansion() throws
    {
        testSingleExprExpansion(.assert)
    }
    
    
    
    func testAssertTrueExpansion() throws
    {
        testSingleExprExpansion(.`true`)
    }
    
    
    
    func testAssertFalseExpansion() throws
    {
        testSingleExprExpansion(.`false`)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilExpansion() throws
    {
        testSingleExprExpansion(.`nil`)
    }
    
    
    
    func testAssertNotNilExpansion() throws
    {
        testSingleExprExpansion(.notNil)
    }
    
    
    
    func testUnwrapExpansion() throws
    {
        testSingleExprExpansion(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualExpansion() throws
    {
        testDoubleExprExpansion(.equal)
    }
    
    
    
    func testAssertNotEqualExpansion() throws
    {
        testDoubleExprExpansion(.notEqual)
    }
    
    
    
    func testAssertIdenticalExpansion() throws
    {
        testDoubleExprExpansion(.identical)
    }
    
    
    
    func testAssertNotIdenticalExpansion() throws
    {
        testDoubleExprExpansion(.notIdentical)
    }
    
    
    
    func testAssertEqualWithAccuracyExpansion() throws
    {
        testDoubleExprExpansion(.equalWithAccuracy)
    }
    
    
    
    func testAssertNotEqualWithAccuracyExpansion() throws
    {
        testDoubleExprExpansion(.notEqualWithAccuracy)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterThanExpansion() throws
    {
        testDoubleExprExpansion(.greaterThan)
    }
    
    
    
    func testAssertGreaterThanOrEqualExpansion() throws
    {
        testDoubleExprExpansion(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessThanOrEqualExpansion() throws
    {
        testDoubleExprExpansion(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessThanExpansion() throws
    {
        testDoubleExprExpansion(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsErrorExpansion() throws
    {
        testSingleExprExpansion(.throwsError)
    }
    
    
    
    func testAssertNoThrowExpansion() throws
    {
        testSingleExprExpansion(.noThrow)
    }



    // MARK: - Fail
    
    func testFailExpansion() throws
    {
        assertMacroExpansion(
            "\(AK.fail.macroDisplayName)(\"message\")",
            expandedSource:
            """
            \(AK.fail.macroInternalName)(
                message:    "message",
                file:       #filePath,
                line:       #line
            )
            """,
            macros: [AK.fail.name : FailMacro.self]
        )
    }
}



// MARK: - Extensions

private extension MacroAssertionExpansionTests
{
    /// Assertion kinds and their associated macro types.
    private static let macros: [AK : any Macro.Type] =
    [
        .assert                 : AssertMacro.self,
        .`true`                 : AssertTrueMacro.self,
        .`false`                : AssertFalseMacro.self,
        
        .`nil`                  : AssertNilMacro.self,
        .notNil                 : AssertNotNilMacro.self,
        .unwrap                 : UnwrapMacro.self,
        
        .equal                  : AssertEqualMacro.self,
        .notEqual               : AssertNotEqualMacro.self,
        .identical              : AssertIdenticalMacro.self,
        .notIdentical           : AssertNotIdenticalMacro.self,
        .equalWithAccuracy      : AssertEqualWithAccuracyMacro.self,
        .notEqualWithAccuracy   : AssertNotEqualWithAccuracyMacro.self,
        
        .greaterThan            : AssertGreaterThanMacro.self,
        .greaterThanOrEqual     : AssertGreaterThanOrEqualMacro.self,
        .lessThanOrEqual        : AssertLessThanOrEqualMacro.self,
        .lessThan               : AssertLessThanMacro.self,
        
        .throwsError            : AssertThrowsErrorMacro.self,
        .noThrow                : AssertNoThrowMacro.self,
        
        .fail                   : FailMacro.self
    ]
    
    
    
    /// Tests the expansion of macros with one evaluated expression.
    /// - Parameter kind: The kind of macro to test.
    private func testSingleExprExpansion(
        _ kind: AK
    )
    {
        guard let macroType: any Macro.Type = Self.macros[kind]
        else
        {
            XCTFail("Expected macro type for kind \(kind)")
            return
        }
        
        let originalSource: String
        let expandedSource: String
        
        switch kind
        {
            case
                .assert,
                .`true`,
                .`false`:
                
                originalSource =
                """
                \(kind.macroDisplayName)(expr, "msg")
                """
                
                expandedSource = BooleanExprWalker.expand(
                    kind:       kind,
                    expr:       "expr",
                    message:    .makeStringLiteral("msg")
                ).description
                
                
            case .throwsError:
                
                originalSource =
                """
                \(kind.macroDisplayName)(expr, "msg") { error in print(error) }
                """
                
                expandedSource =
                """
                \(kind.macroInternalName)(
                    expr:           {
                        expr
                    },
                    exprText:       "expr",
                    message:        "msg",
                    file:           #filePath,
                    line:           #line,
                    errorHandler:   { error in
                        print(error)
                    }
                )
                """
                
            case .noThrow:
                
                originalSource = 
                """
                \(kind.macroDisplayName)(expr, "msg")
                """
                
                expandedSource =
                """
                \(kind.macroInternalName)(
                    expr:       {
                        expr
                    },
                    exprText:   "expr",
                    message:    "msg",
                    file:       #filePath,
                    line:       #line
                )
                """
                
            default:
                
                originalSource =
                """
                \(kind.macroDisplayName)(expr, "msg")
                """
                
                expandedSource =
                """
                \(kind.macroInternalName)(
                    expr:       expr,
                    exprText:   "expr",
                    message:    "msg",
                    file:       #filePath,
                    line:       #line
                )
                """
        }
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     expandedSource,
            macros:             [kind.name : macroType]
        )
    }
    
    
    
    /// Tests the expansion of macros with two evaluated expressions.
    /// - Parameter kind: The kind of macro to test.
    private func testDoubleExprExpansion(
        _ kind: AK
    )
    {
        guard let macroType: any Macro.Type = Self.macros[kind]
        else
        {
            XCTFail("Expected macro type for kind \(kind)")
            return
        }
        
        let originalSource: String
        let expandedSource: String
        
        switch kind
        {
            case .equal:
                
                originalSource =
                """
                \(kind.macroDisplayName)(expr1, expr2, "msg", options: opts)
                """
                
                expandedSource =
                """
                \(kind.macroInternalName)(
                    expected:       expr1,
                    actual:         expr2,
                    expectedText:   "expr1",
                    actualText:     "expr2",
                    message:        "msg",
                    file:           #filePath,
                    line:           #line,
                    options:        opts
                )
                """
                
            case
                .equalWithAccuracy,
                .notEqualWithAccuracy:
                
                originalSource =
                """
                \(kind.macroDisplayName)(expr1, expr2, "msg", accuracy: 0.1)
                """
                
                expandedSource =
                """
                \(kind.macroInternalName)(
                    expr1:      expr1,
                    expr2:      expr2,
                    expr1Text:  "expr1",
                    expr2Text:  "expr2",
                    accuracy:   0.1,
                    message:    "msg",
                    file:       #filePath,
                    line:       #line
                )
                """
                
            default:
                
                originalSource =
                """
                \(kind.macroDisplayName)(expr1, expr2, "msg")
                """
                
                expandedSource =
                """
                \(kind.macroInternalName)(
                    expr1:      expr1,
                    expr2:      expr2,
                    expr1Text:  "expr1",
                    expr2Text:  "expr2",
                    message:    "msg",
                    file:       #filePath,
                    line:       #line
                )
                """
        }
        
        assertMacroExpansion(
            originalSource,
            expandedSource:     expandedSource,
            macros:             [kind.name : macroType]
        )
    }
}
