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



internal final class FunctionAssertionOutputTests: XCTestKitCase
{
    private typealias AK = AssertionKind
    
    /// A description of a failure.
    private static let message: String = "hello world"
    
    
    
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
        let actual: String? = captureFailureMessage
        {
            XCTKAssert(
                false,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.assert.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertTrueFailureMessage() throws
    {
        let actual: String? = captureFailureMessage
        {
            XCTKAssertTrue(
                false,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.true.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertFalseFailureMessage() throws
    {
        let actual: String? = captureFailureMessage
        {
            XCTKAssertFalse(
                true,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.false.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailureMessage() throws
    {
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNil(
                10,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.nil.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotNilFailureMessage() throws
    {
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNotNil(
                Optional<Int>(nil),
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.notNil.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUnwrapFailureMessage() throws
    {
        let actual: String? = captureFailureMessage
        {
            _ = try? XCTKUnwrap(
                Optional<Int>(nil),
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.unwrap.name) failed - \(Self.message)
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
        
        let exp : User  = .init(name: "a")
        let act : User  = .init(name: "b")
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertEqual(
                exp,
                act,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.equal.name) failed - \(Self.message)

        \(typeName(of: exp)) differs at:

            .name, character 1
                Expected:   \(quote(exp.name))
                Actual:     \(quote(act.name))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNotEqualFailureMessage() throws
    {
        let expr: Int = 10
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNotEqual(
                expr,
                expr,
                Self.message
            )
        }
        
        let reason: String = "both values equal (\(quote(expr)))"
        
        let expected: String =
        """
        \(AK.notEqual.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testIdenticalFailureMessage() throws
    {
        let expr1   : NSObject  = .init()
        let expr2   : NSObject  = .init()
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertIdentical(
                expr1,
                expr2,
                Self.message
            )
        }
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains("\(AK.identical.name) failed:"))
        XCTAssertTrue(actual!.contains(" is not identical to"))
        XCTAssertTrue(actual!.contains(" - \(Self.message)"))
    }
    
    
    
    func testNotIdenticalFailureMessage() throws
    {
        let expr: NSObject = .init()
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNotIdentical(
                expr,
                expr,
                Self.message
            )
        }
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains("\(AK.notIdentical.name) failed:"))
        XCTAssertTrue(actual!.contains(" both values are identical"))
        XCTAssertTrue(actual!.contains(" - \(Self.message)"))
    }
    
    
    
    func testAssertEqualFloatAccuracyFailureMessage() throws
    {
        let expr1       : Double    = 1.0
        let expr2       : Double    = 2.0
        let accuracy    : Double    = 0.5
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not equal to"
            + " (\(quote(expr2))) +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.equalWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertEqualIntAccuracyFailureMessage() throws
    {
        let expr1       : Int   = 0
        let expr2       : Int   = 2
        let accuracy    : Int   = 1
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not equal to"
            + " (\(quote(expr2))) +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.equalWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotEqualFloatAccuracyFailureMessage() throws
    {
        let expr1       : Double    = 0.0
        let expr2       : Double    = 1.0
        let accuracy    : Double    = 1.0
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNotEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "both values equal (\(quote(expr1)))"
            + " +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotEqualIntAccuracyFailureMessage() throws
    {
        let expr1       : Int   = 0
        let expr2       : Int   = 1
        let accuracy    : Int   = 1
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNotEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "both values equal (\(quote(expr1)))"
            + " +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterThanFailureMessage() throws
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertGreaterThan(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not greater than"
            + " (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.greaterThan.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertGreaterThanOrEqualFailureMessage() throws
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertGreaterThanOrEqual(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not greater than or equal"
            + " to (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.greaterThanOrEqual.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanOrEqualFailureMessage() throws
    {
        let expr1   : Int   = 1
        let expr2   : Int   = 0
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertLessThanOrEqual(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not less than or equal"
            + " to (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.lessThanOrEqual.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanFailureMessage() throws
    {
        let expr1   : Int   = 1
        let expr2   : Int   = 0
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertLessThan(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not less than"
            + " (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.lessThan.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsErrorFailureMessage() throws
    {
        let expr: () throws -> Int = { return 0 }
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertThrowsError(
                expr,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.throwsError.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNoThrowFailureMessage() throws
    {
        let error   : TestError         = .init()
        let expr    : () throws -> Int  = { throw error }
        
        let actual: String? = captureFailureMessage
        {
            XCTKAssertNoThrow(
                try expr(),
                Self.message
            )
        }
        
        let reason: String = "threw error \(quote(error))"
        
        let expected: String =
        """
        \(AK.noThrow.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Fail
    
    func testFailFailureMessage() throws
    {
        let actual: String? = captureFailureMessage
        {
            XCTKFail(
                Self.message,
                file: #filePath,
                line: #line
            )
        }
        
        XCTAssertEqual(Self.message, actual)
    }
}
