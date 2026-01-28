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
@testable import XCTestKitTestUtilities



internal final class MacroAssertionOutputTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    override func setUp()
    {
        super.setUp()
        
        /// Enable continuation after failure since all tests expect the
        /// internal macro call to fail, so its output can be tested.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Boolean

    func testAssertFailureMessage() throws
    {
        let exprText: String = "a && b"
        
        let evaluated: [XCTKBooleanExpr] =
        [
            .init("a", false)
        ]
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertMacro(
                result:         false,
                exprText:       exprText,
                evaluated:      evaluated,
                notEvaluated:   1,
                message:        Self.message,
                file:           #filePath,
                line:           #line
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
        
        let evaluated: [XCTKBooleanExpr] =
        [
            .init("a", false),
            .init("b", false)
        ]
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertTrueMacro(
                result:         false,
                exprText:       exprText,
                evaluated:      evaluated,
                notEvaluated:   0,
                message:        Self.message,
                file:           #filePath,
                line:           #line
            )
        }
        
        let expected: String =
        """
        \(AK.`true`.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)

            a = false ←
            b = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertFalseFailureMessage() throws
    {
        let exprText: String = "a && b"
        
        let evaluated: [XCTKBooleanExpr] =
        [
            .init("a", true),
            .init("b", true)
        ]
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertFalseMacro(
                result:         true,
                exprText:       exprText,
                evaluated:      evaluated,
                notEvaluated:   0,
                message:        Self.message,
                file:           #filePath,
                line:           #line
            )
        }
        
        let expected: String =
        """
        \(AK.`false`.macroDisplayName) failed - \(Self.message)

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
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNilMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.`nil`.macroDisplayName) failed - \(Self.message)

        Expression: \(exprText)
        Actual:     \(expr)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotNilFailureMessage() throws
    {
        let expr        : Int?      = nil
        let exprText    : String    = "something"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNotNilMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line
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
        
        let actual: String? = captureFailureMessage
        {
            _ = try? _XCTKUnwrapMacro(
                expr:       expr,
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line
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
        
        let actual: String? = captureFailureMessage
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
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNotEqualMacro(
                expr1:      expr,
                expr2:      expr,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.notEqual.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        both values equal (\(quote(expr)))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testIdenticalFailureMessage() throws
    {
        let expr1       : NSObject  = .init()
        let expr2       : NSObject  = .init()
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertIdenticalMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let header: String
            = "\(AK.identical.macroDisplayName) failed - \(Self.message)"
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains(header))
        XCTAssertTrue(actual!.contains("Expression 1: \(expr1Text)"))
        XCTAssertTrue(actual!.contains("Expression 2: \(expr2Text)"))
        XCTAssertTrue(actual!.contains("is not identical to"))
    }
    
    
    
    func testNotIdenticalFailureMessage() throws
    {
        let expr        : NSObject  = .init()
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNotIdenticalMacro(
                expr1:      expr,
                expr2:      expr,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let header: String
            = "\(AK.notIdentical.macroDisplayName) failed - \(Self.message)"
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains(header))
        XCTAssertTrue(actual!.contains("Expression 1: \(expr1Text)"))
        XCTAssertTrue(actual!.contains("Expression 2: \(expr2Text)"))
        XCTAssertTrue(actual!.contains("both values are identical"))
    }
    
    
    
    func testAssertEqualFloatAccuracyFailureMessage() throws
    {
        let expr1       : Double    = 1.0
        let expr2       : Double    = 2.0
        let accuracy    : Double    = 0.5
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
    """
    \(AK.equalWithAccuracy.macroDisplayName) failed - \(Self.message)

    Expression 1: \(expr1Text)
    Expression 2: \(expr2Text)

    (\(quote(expr1))) is not equal to (\(quote(expr2))) +/- (\(quote(accuracy)))
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
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
    """
    \(AK.equalWithAccuracy.macroDisplayName) failed - \(Self.message)

    Expression 1: \(expr1Text)
    Expression 2: \(expr2Text)

    (\(quote(expr1))) is not equal to (\(quote(expr2))) +/- (\(quote(accuracy)))
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
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNotEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        both values equal (\(quote(expr1))) +/- (\(quote(accuracy)))
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
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNotEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                accuracy:   accuracy,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        both values equal (\(quote(expr1))) +/- (\(quote(accuracy)))
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
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertGreaterThanMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.greaterThan.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        (\(quote(expr1))) is not greater than (\(quote(expr2)))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertGreaterThanOrEqualFailureMessage() throws
    {
        let expr1       : Int       = 0
        let expr2       : Int       = 1
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertGreaterThanOrEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.greaterThanOrEqual.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        (\(quote(expr1))) is not greater than or equal to (\(quote(expr2)))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanOrEqualFailureMessage() throws
    {
        let expr1       : Int       = 1
        let expr2       : Int       = 0
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertLessThanOrEqualMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.lessThanOrEqual.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        (\(quote(expr1))) is not less than or equal to (\(quote(expr2)))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanFailureMessage() throws
    {
        let expr1       : Int       = 1
        let expr2       : Int       = 0
        let expr1Text   : String    = "something"
        let expr2Text   : String    = "anything"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertLessThanMacro(
                expr1:      expr1,
                expr2:      expr2,
                expr1Text:  expr1Text,
                expr2Text:  expr2Text,
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        let expected: String =
        """
        \(AK.lessThan.macroDisplayName) failed - \(Self.message)

        Expression 1: \(expr1Text)
        Expression 2: \(expr2Text)

        (\(quote(expr1))) is not less than (\(quote(expr2)))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsErrorFailureMessage() throws
    {
        let exprText: String = "something"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertThrowsErrorMacro(
                expr:           { },
                exprText:       exprText,
                message:        Self.message,
                file:           #filePath,
                line:           #line,
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
        let error       : TestError     = .init()
        let exprText    : String        = "something"
        
        let actual: String? = captureFailureMessage
        {
            _XCTKAssertNoThrowMacro(
                expr:       { throw error },
                exprText:   exprText,
                message:    Self.message,
                file:       #filePath,
                line:       #line
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
        let actual: String? = captureFailureMessage
        {
            _XCTKFailMacro(
                message:    Self.message,
                file:       #filePath,
                line:       #line
            )
        }
        
        XCTAssertEqual(Self.message, actual)
    }
}



// MARK: - Extensions

private extension MacroAssertionOutputTests
{
    /// A description of a failure.
    static let message: String = "hello world"
    
    
    
    /// Captures the failure message of the given closure.
    /// - Parameter body: The closure to call.
    /// - Returns: The failure message of the given closure.
    func captureFailureMessage(
        _ body: () -> Void
    ) -> String?
    {
        var captured            : String?   = nil
        var isInsideBodyClosure : Bool      = false
        
        XCTExpectFailure
        {
            guard
                isInsideBodyClosure,
                captured == nil
            else
            {
                /// Only mark failures as expected when the failure occurs
                /// inside the `body` closure, and it is the first failure.
                ///
                /// This ensures that the only expected failure is that of the
                /// underlying macro, which prevents tests from incorrectly
                /// passing when written incorrectly.
                ///
                /// For example, if the `body` closure does not fail as
                /// expected, the output-validating assertion outside the
                /// closure would fail. Without this guard, that failure would
                /// be incorrectly marked as expected.
                return false
            }
            
            var message : String    = $0.compactDescription
            let prefix  : String    = "failed - "
            
            if message.hasPrefix(prefix)
            {
                /// Remove XCTest's prefix so only XCTestKit's output is tested.
                message = String(message.dropFirst(prefix.count))
            }
            
            captured = message
            
            return true
        }
        
        isInsideBodyClosure = true
        body()
        isInsideBodyClosure = false
        
        return captured
    }
}
