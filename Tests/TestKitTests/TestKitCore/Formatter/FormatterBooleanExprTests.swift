//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



internal final class FormatterBooleanExprTests: XCTestCaseStopOnFail
{
    // MARK: - AND chains
    
    func testAndChainFirstFalseShortCircuits()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testAndChainMiddleFalseShortCircuits()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testAndChainLastFalseNoShortCircuit()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    func testOrChainFirstTrueShortCircuits()
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testOrChainAllFalseNoShortCircuit()
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [BooleanExpr] =
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
    
    func testNestedOrInAndExprWithFalseLHS()
    {
        let exprText: String = "(a || b) && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testNestedOrInAndExprWithTrueLHS()
    {
        let exprText: String = "(a || b) && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testParenthesizedSingleExprUnwrapping()
    {
        let exprText: String = "(a)"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testDeeplyNestedExpr()
    {
        let exprText: String = "((a && (b)) || c) && d"
        
        let evaluated: [BooleanExpr] =
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
    
    func testSingleExprAssertTrueWhenFalse()
    {
        let exprText: String = "isValid"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testSingleExprAssertFalseWhenTrue()
    {
        let exprText: String = "isValid"
        
        let evaluated: [BooleanExpr] =
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
    
    func testFunctionCallAsLeaf()
    {
        let exprText: String = "isValid() && isEnabled"
        
        let evaluated: [BooleanExpr] =
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
    
    func testNegation()
    {
        let exprText: String = "(!a || !(!b)) && !(!(!c))"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testOperatorPrecedence()
    {
        let exprText: String = "a || b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testPropertyAccessExprs()
    {
        let exprText: String = "obj.isActive && obj.isValid && obj.value >= 30"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testMethodCalls()
    {
        let exprText: String = "obj.contains(key) && value.isValid()"
        
        let evaluated: [BooleanExpr] =
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
    
    func testShowAllEvaluatedDisabledWithNotEvaluatedCount()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testShowAllEvaluatedAndCountDisabled()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testShowAllEvaluatedDisabledHidesPassingExprs()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testShowAllEvaluatedDisabledWithMultipleFailures()
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testShowEvaluatedCountDisabledHidesCount()
    {
        let exprText: String = "a && b && c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testShowEvaluatedCountEnabledWithAllExprsEvaluated()
    {
        let exprText: String = "a && b"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testMaxDiffsTruncatesExprs()
    {
        let exprText: String = "a || b || c || d || e"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testMaxDiffsWithCountDiffs()
    {
        let exprText: String = "a || b || c || d || e"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testMaxDiffsOneWithCountDiffs()
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testMaxDiffsWithShowAllEvaluatedDisabled()
    {
        let exprText: String = "a || b || c || d || e"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testMaxDiffsAtExactLimitNoTruncation()
    {
        let exprText: String = "a || b || c"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testLongExprTextTruncated()
    {
        /// Available width = 50 - 12 (label) = 38
        /// Truncated to 38 characters: 35 `exprText` characters + 3 (ellipsis)
        
        let exprText: String = "veryLongVariableNameA && veryLongVariableNameB"
            + " && veryLongVariableNameC"
        
        let evaluated: [BooleanExpr] =
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
    
    
    
    func testLongEvaluatedExprTextTruncated()
    {
        /// Available width = 50 - 4 (indent) = 46
        /// Truncated to 46 characters: 33 expression characters + 3 (ellipsis)
        /// + 10 (result)
        
        let exprText: String = "a && b"
        
        let evaluated: [BooleanExpr] =
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
