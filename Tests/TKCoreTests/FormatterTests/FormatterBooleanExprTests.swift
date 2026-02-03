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
@testable import TKTestSupport



internal final class FormatterBooleanExprTests: XCTestCase
{
    // MARK: - AND chains
    
    func testAndChainFirstFalseShortCircuits() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   2,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←

            (2 expressions not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAndChainMiddleFalseShortCircuits() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true
            b = false ←

            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAndChainLastFalseNoShortCircuit() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", true),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true
            b = true
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - OR chains
    
    func testOrChainFirstTrueShortCircuits() throws
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   2,
            expectedValue:  false,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true ←

            (2 expressions not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrChainAllFalseNoShortCircuit() throws
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = false ←
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nested expressions
    
    func testNestedOrInAndExprWithFalseLHS() throws
    {
        let exprText: String = "(a || b) && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOrInAndExprWithTrueLHS() throws
    {
        let exprText: String = "(a || b) && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true
            c = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testParenthesizedSingleExprUnwrapping() throws
    {
        let exprText: String = "(a)"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDeeplyNestedExpr() throws
    {
        let exprText: String = "((a && (b)) || c) && d"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", false),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true
            b = false ←
            c = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Single expression
    
    func testSingleExprAssertTrueWhenFalse() throws
    {
        let exprText: String = "isValid"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init(exprText, false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            \(exprText) = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleExprAssertFalseWhenTrue() throws
    {
        let exprText: String = "isValid"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init(exprText, true)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  false,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            \(exprText) = true ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Function leaves
    
    func testFunctionCallAsLeaf() throws
    {
        let exprText: String = "isValid() && isEnabled"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("isValid()", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            isValid() = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Other expressions
    
    func testNegation() throws
    {
        let exprText: String = "(!a || !(!b)) && !(!(!c))"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("!a", false),
            .init("!!b", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            !a = false ←
            !!b = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOperatorPrecedence() throws
    {
        let exprText: String = "a || b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", true),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = true
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPropertyAccessExprs() throws
    {
        let exprText: String = "obj.isActive && obj.isValid && obj.value >= 30"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("obj.isActive", true),
            .init("obj.isValid", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            obj.isActive = true
            obj.isValid = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMethodCalls() throws
    {
        let exprText: String = "obj.contains(key) && value.isValid()"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("obj.contains(key)", false),
            .init("value.isValid()", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init()
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            obj.contains(key) = false ←
            value.isValid() = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Options
    
    func testShowAllEvaluatedDisabledWithNotEvaluatedCount() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init(showAllEvaluated: false)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            b = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowAllEvaluatedAndCountDisabled() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init(
                                showAllEvaluated:       false,
                                showNotEvaluatedCount:  false
                            )
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            b = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowAllEvaluatedDisabledHidesPassingExprs() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", true),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(showAllEvaluated: false)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowAllEvaluatedDisabledWithMultipleFailures() throws
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(showAllEvaluated: false)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = false ←
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowEvaluatedCountDisabledHidesCount() throws
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   2,
            expectedValue:  true,
            options:        .init(showNotEvaluatedCount: false)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowEvaluatedCountEnabledWithAllExprsEvaluated() throws
    {
        let exprText: String = "a && b"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(showNotEvaluatedCount: true)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true
            b = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsTruncatesExprs() throws
    {
        let exprText: String = "a || b || c || d || e"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false),
            .init("c", false),
            .init("d", false),
            .init("e", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(maxDiffs: 2)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = false ←
        
            ... and more expressions (limit: 2)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithCountDiffs() throws
    {
        let exprText: String = "a || b || c || d || e"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false),
            .init("c", false),
            .init("d", false),
            .init("e", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(
                                maxDiffs:       2,
                                countDiffs:     true
                            )
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = false ←
        
            ... and 3 more expressions
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsOneWithCountDiffs() throws
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(
                                maxDiffs:       1,
                                countDiffs:     true
                            )
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
        
            ... and 2 more expressions
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithShowAllEvaluatedDisabled() throws
    {
        let exprText: String = "a || b || c || d || e"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", false),
            .init("c", true),
            .init("d", false),
            .init("e", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  false,
            options:        .init(
                                maxDiffs:           2,
                                countDiffs:         true,
                                showAllEvaluated:   false
                            )
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = true ←
            c = true ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsAtExactLimitNoTruncation() throws
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false),
            .init("c", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   0,
            expectedValue:  true,
            options:        .init(maxDiffs: 3)
        )
        
        let expected: String =
        """
        Expression: \(exprText)

            a = false ←
            b = false ←
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testLongExprTextTruncated() throws
    {
        /// Available width = 50 - 12 (label) = 38
        /// Truncated to 38 characters: 35 `exprText` characters + 3 (ellipsis)
        
        let exprText: String = "veryLongVariableNameA && veryLongVariableNameB"
            + " && veryLongVariableNameC"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("veryLongVariableNameA", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   2,
            expectedValue:  true,
            options:        .init(maxLineLength: 50)
        )
        
        let expected: String =
        """
        Expression: \(exprText.prefix(35))...

            veryLongVariableNameA = false ←
        
            (2 expressions not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testLongEvaluatedExprTextTruncated() throws
    {
        /// Available width = 50 - 4 (indent) = 46
        /// Truncated to 46 characters: 33 expression characters + 3 (ellipsis)
        /// + 10 (result)
        
        let exprText: String = "a && b"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("someObject.someProperty.someNestedProperty.value", false)
        ]
        
        let actual: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   1,
            expectedValue:  true,
            options:        .init(maxLineLength: 50)
        )

        let expected: String =
        """
        Expression: \(exprText)

            \(evaluated[0].text.prefix(33))... = false ←

            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
}
