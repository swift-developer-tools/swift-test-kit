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
@testable import XCTestKit
@testable import TKTestSupport



internal final class MacroAssertionOutputTests: XCTestKitCase
{
    private typealias AK = AssertionKind
    
    private static let message: String = "hello world"
    
    
    
    // MARK: - Boolean

    func testAssertFailureMessage() throws
    {
        let exprText: String = "a && b"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false)
        ]
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertMacro(
                result:         false,
                exprText:       exprText,
                evaluated:      evaluated,
                notEvaluated:   1,
                message:        Self.message,
                file:           #filePath,
                line:           #line,
                options:        nil
            )
        }
        
        let expected: String =
        """
        \(AK.assert.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)

            a = false ←

            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertTrueFailureMessage() throws
    {
        let exprText: String = "a || b"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false)
        ]
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertTrueMacro(
                result:         false,
                exprText:       exprText,
                evaluated:      evaluated,
                notEvaluated:   0,
                message:        Self.message,
                file:           #filePath,
                line:           #line,
                options:        nil
            )
        }
        
        let expected: String =
        """
        \(AK.true.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)

            a = false ←
            b = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertFalseFailureMessage() throws
    {
        let exprText: String = "a && b"
        
        let evaluated: [TKBooleanExpr] =
        [
            .init("a", true),
            .init("b", true)
        ]
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertFalseMacro(
                result:         true,
                exprText:       exprText,
                evaluated:      evaluated,
                notEvaluated:   0,
                message:        Self.message,
                file:           #filePath,
                line:           #line,
                options:        nil
            )
        }
        
        let expected: String =
        """
        \(AK.false.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)

            a = true ←
            b = true ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailureMessage() throws
    {
        let expr        : Int       = 10
        let exprText    : String    = "something"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNilMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let expected: String =
        """
        \(AK.nil.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)
        Actual:     \(expr)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotNilFailureMessage() throws
    {
        let expr        : Int?      = nil
        let exprText    : String    = "something"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNotNilMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let expected: String =
        """
        \(AK.notNil.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUnwrapFailureMessage() throws
    {
        let expr        : Int?      = nil
        let exprText    : String    = "something"
        
        let actual: String? = withOneExpectedFailure
        {
            _ = try _XCTKUnwrapMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let expected: String =
        """
        \(AK.unwrap.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailureMessage() throws
    {
        struct User: Equatable
        {
            let name: String
        }
        
        let exp     : User      = .init(name: "a")
        let act     : User      = .init(name: "b")
        let expText : String    = "something"
        let actText : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertEqualMacro(
                expected:       exp,
                actual:         act,
                expectedText:   expText,
                actualText:     actText,
                message:        Self.message,
                file:           #filePath,
                line:           #line,
                options:        nil
            )
        }
        
        let expected: String =
        """
        \(AK.equal.macroDisplayName) failed - \(Self.message)

        Expected: \(expText)
        Actual:   \(actText)

        \(typeName(of: exp)) differs at:

            .name, character 1
                Expected:   \(quote(exp.name))
                Actual:     \(quote(act.name))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNotEqualFailureMessage() throws
    {
        let expr        : Int       = 10
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNotEqualMacro(
                expr1:      expr,
                expr2:      expr,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "both values equal (\(quote(expr)))"
        
        let expected: String =
        """
        \(AK.notEqual.macroDisplayName) failed: \(reason) - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testIdenticalFailureMessage() throws
    {
        let expr1       : NSObject  = .init()
        let expr2       : NSObject  = .init()
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertIdenticalMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let header: String = "\(AK.identical.macroDisplayName) failed:"
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains(header))
        XCTAssertTrue(actual!.contains(" is not identical to"))
        XCTAssertTrue(actual!.contains(" - \(Self.message)"))
        XCTAssertTrue(actual!.contains("Expression 1: \(expr1Text)"))
        XCTAssertTrue(actual!.contains("Expression 2: \(expr2Text)"))
    }
    
    
    
    func testNotIdenticalFailureMessage() throws
    {
        let expr        : NSObject  = .init()
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNotIdenticalMacro(
                expr1:      expr,
                expr2:      expr,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let header: String = "\(AK.notIdentical.macroDisplayName) failed:"
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains(header))
        XCTAssertTrue(actual!.contains(" both values are identical"))
        XCTAssertTrue(actual!.contains(" - \(Self.message)"))
        XCTAssertTrue(actual!.contains("Expression 1: \(expr1Text)"))
        XCTAssertTrue(actual!.contains("Expression 2: \(expr2Text)"))
    }
    
    
    
    func testAssertEqualFloatAccuracyFailureMessage() throws
    {
        let expr1       : Double    = 1.0
        let expr2       : Double    = 2.0
        let accuracy    : Double    = 0.5
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not equal to"
            + " (\(quote(expr2))) +/- (\(quote(accuracy)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.equalWithAccuracy.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertEqualIntAccuracyFailureMessage() throws
    {
        let expr1       : Int       = 0
        let expr2       : Int       = 2
        let accuracy    : Int       = 1
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not equal to"
            + " (\(quote(expr2))) +/- (\(quote(accuracy)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.equalWithAccuracy.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotEqualFloatAccuracyFailureMessage() throws
    {
        let expr1       : Double    = 0.0
        let expr2       : Double    = 1.0
        let accuracy    : Double    = 1.0
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNotEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "both values equal (\(quote(expr1)))"
            + " +/- (\(quote(accuracy)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotEqualIntAccuracyFailureMessage() throws
    {
        let expr1       : Int       = 0
        let expr2       : Int       = 1
        let accuracy    : Int       = 1
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNotEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "both values equal (\(quote(expr1)))"
            + " +/- (\(quote(accuracy)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterThanFailureMessage() throws
    {
        let expr1       : Int       = 0
        let expr2       : Int       = 1
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertGreaterThanMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not greater than"
            + " (\(quote(expr2)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.greaterThan.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertGreaterThanOrEqualFailureMessage() throws
    {
        let expr1       : Int       = 0
        let expr2       : Int       = 1
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertGreaterThanOrEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not greater than or equal"
            + " to (\(quote(expr2)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.greaterThanOrEqual.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanOrEqualFailureMessage() throws
    {
        let expr1       : Int       = 1
        let expr2       : Int       = 0
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertLessThanOrEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not less than or equal"
            + " to (\(quote(expr2)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.lessThanOrEqual.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanFailureMessage() throws
    {
        let expr1       : Int       = 1
        let expr2       : Int       = 0
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertLessThanMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not less than"
            + " (\(quote(expr2)))"
        
        let header: String = "\(reason) - \(Self.message)"
        
        let expected: String =
        """
        \(AK.lessThan.macroDisplayName) failed: \(header)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsErrorFailureMessage() throws
    {
        let expr        : () throws -> Int  = { return 0 }
        let exprText    : String            = "something"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertThrowsErrorMacro(
                expr:           expr,
                exprText:       exprText,
                message:        Self.message,
                file:           #filePath,
                line:           #line,
                options:        nil,
                errorHandler:   { _ in }
            )
        }
        
        let expected: String =
        """
        \(AK.throwsError.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNoThrowFailureMessage() throws
    {
        let error       : TestError         = .init()
        let expr        : () throws -> Int  = { throw error }
        let exprText    : String            = "something"
        
        let actual: String? = withOneExpectedFailure
        {
            _XCTKAssertNoThrowMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line,
                options:    nil
            )
        }
        
        let expected: String =
        """
        \(AK.noThrow.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)
        Threw:      \(error)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Fail
    
    func testFailFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            _XCTKFailMacro(
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        XCTAssertEqual(Self.message, actual)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertAllSatisfyFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertAllSatisfy(
                [2, 3, 6],
                { $0 % 2 == 0 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAll.macroDisplayName) failed - \(Self.message)
        
        Collection count: 3
        
        Collection: [2, 3, 6]
        Predicate:  { $0 % 2 == 0 }
        
        Failed: 1 of 3
        
            [1]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertAnySatisfyFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertAnySatisfy(
                [1, 3, 5],
                { $0 % 2 == 0 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAny.macroDisplayName) failed - \(Self.message)
        
        Collection count: 3
        
        Collection: [1, 3, 5]
        Predicate:  { $0 % 2 == 0 }
        
        Expected: at least 1 match
        Actual:   0 matched
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNoneSatisfyFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertNoneSatisfy(
                [1, 2, 3],
                { $0 % 2 == 0 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyNone.macroDisplayName) failed - \(Self.message)
        
        Collection count: 3
        
        Collection: [1, 2, 3]
        Predicate:  { $0 % 2 == 0 }
        
        Matched: 1 of 3
        
            [1]: 2
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSatisfyAtLeastFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertSatisfy(
                [1, 2, 3, 4],
                atLeast: 3,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAtLeast.macroDisplayName) failed - \(Self.message)
        
        Collection count: 4
        
        Collection: [1, 2, 3, 4]
        Predicate:  { $0 > 2 }
        
        Expected: at least 3 matches
        Actual:   2 matched
        
            Matched: [2-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSatisfyAtMostFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertSatisfy(
                [1, 2, 3, 4],
                atMost: 1,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAtMost.macroDisplayName) failed - \(Self.message)
        
        Collection count: 4
        
        Collection: [1, 2, 3, 4]
        Predicate:  { $0 > 2 }
        
        Expected: up to 1 match
        Actual:   2 matched
        
            Matched: [2-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSatisfyRangeFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertSatisfy(
                [3, 2, 1, 4, 5],
                range: 0...1,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyRange.macroDisplayName) failed - \(Self.message)
        
        Collection count: 5
        
        Collection: [3, 2, 1, 4, 5]
        Predicate:  { $0 > 2 }
        
        Expected: 0-1 matches
        Actual:   3 matched
        
            Matched: [0], [3-4]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertExactlyFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertExactly(
                [1, 2, 3, 4],
                count: 3,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.exactly.macroDisplayName) failed - \(Self.message)
        
        Collection count: 4
        
        Collection: [1, 2, 3, 4]
        Predicate:  { $0 > 2 }
        
        Expected: exactly 3 matches
        Actual:   2 matched
        
            Matched: [2-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertExactlyOneFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertExactlyOne(
                [1, 2, 3],
                { $0 > 1 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.exactlyOne.macroDisplayName) failed - \(Self.message)
        
        Collection count: 3
        
        Collection: [1, 2, 3]
        Predicate:  { $0 > 1 }
        
        Expected: exactly 1 match
        Actual:   2 matched
        
            Matched: [1-2]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSortedFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertSorted(
                [1, 3, 2, 4],
                by: <,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.sorted.macroDisplayName) failed - \(Self.message)
        
        Collection count: 4
        
        Collection: [1, 3, 2, 4]
        Predicate:  <
        
        Not sorted at:
        
            [1]: 3
            [2]: 2
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertUniqueFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertUnique(
                [1, 2, 3, 2],
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.unique.macroDisplayName) failed - \(Self.message)
        
        Collection count: 4
        
        Collection: [1, 2, 3, 2]
        
        Duplicates: 1 value
        
            2: [1], [3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertUniqueByKeyFailureMessage() throws
    {
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertUnique(
                ["a", "b", "cc"],
                by: { $0.count },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.uniqueByKey.macroDisplayName) failed - \(Self.message)
        
        Collection count: 3
        
        Collection: ["a", "b", "cc"]
        Predicate:  { $0.count }
        
        Duplicates: 1 key
        
            Key 1:
                [0]: \(quote("a"))
                [1]: \(quote("b"))
        """
        
        XCTAssertEqual(expected, actual)
    }
}
