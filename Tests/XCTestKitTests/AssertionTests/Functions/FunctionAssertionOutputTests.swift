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
    typealias AK = AssertionKind
    
    
    
    // MARK: - Boolean
    
    func testAssertFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.assert.name) failed")
        }
        
        XCTKAssert(false)
    }
    
    
    
    func testAssertFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.assert.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssert(false, message)
    }
    
    
    
    func testAssertTrueFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`true`.name) failed")
        }
        
        XCTKAssertTrue(false)
    }
    
    
    
    func testAssertTrueFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`true`.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertTrue(false, message)
    }
    
    
    
    func testAssertTrueWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`true`.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertTrue(try TestError.throwError())
    }
    
    
    
    func testAssertFalseFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`false`.name) failed")
        }
        
        XCTKAssertFalse(true)
    }
    
    
    
    func testAssertFalseFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`false`.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertFalse(true, message)
    }
    
    
    
    func testAssertFalseWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`false`.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertFalse(try TestError.throwError())
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`nil`.name) failed")
        }
        
        XCTKAssertNil(false)
    }
    
    
    
    func testAssertNilFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`nil`.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertNil(false, message)
    }
    
    
    
    func testAssertNilWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`nil`.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertNil(try TestError.throwError())
    }
    
    
    
    func testAssertNotNilFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.notNil.name) failed")
        }
        
        XCTKAssertNotNil(nil)
    }
    
    
    
    func testAssertNotNilFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.notNil.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertNotNil(nil, message)
    }
    
    
    
    func testAssertNotNilWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.notNil.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertNotNil(try TestError.throwError())
    }
    
    
    
    func testUnwrapFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.unwrap.name) failed")
        }
        
        _ = try XCTKUnwrap(Optional<Int>(nil))
    }
    
    
    
    func testUnwrapFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.unwrap.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        _ = try XCTKUnwrap(Optional<Int>(nil), message)
    }
    
    
    
    func testUnwrapWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.unwrap.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Bool = { try TestError.throwError() }
        
        _ = try XCTKUnwrap(try expr())
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.equal.name) failed")
        }
        
        XCTKAssertEqual(0, 1)
    }
    
    
    
    func testAssertEqualFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.equal.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertEqual(0, 1, message)
    }
    
    
    
    func testAssertEqualWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.equal.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertEqual(true, try TestError.throwError())
    }
    
    
    
    func testAssertNotEqualFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqual.name) failed"
            )
        }
        
        XCTKAssertNotEqual(1, 1)
    }
    
    
    
    func testAssertNotEqualFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqual.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertNotEqual(1, 1, message)
    }
    
    
    
    func testAssertNotEqualWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqual.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertNotEqual(true, try TestError.throwError())
    }
    
    
    
    func testAssertIdenticalFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.identical.name) failed"
            )
        }
        
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        XCTKAssertIdentical(object1, object2)
    }
    
    
    
    func testAssertIdenticalFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.identical.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        XCTKAssertIdentical(object1, object2, message)
    }
    
    
    
    func testAssertIdenticalWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.identical.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr1 = TestError() as AnyObject
        
        let expr2: () throws -> AnyObject = { try TestError.throwError() }
        
        XCTKAssertIdentical(expr1, try expr2())
    }
    
    
    
    func testAssertNotIdenticalFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notIdentical.name) failed"
            )
        }
        
        let object = TestError() as AnyObject
        
        XCTKAssertNotIdentical(object, object)
    }
    
    
    
    func testAssertNotIdenticalFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notIdentical.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        let object = TestError() as AnyObject
        
        XCTKAssertNotIdentical(object, object, message)
    }
    
    
    
    func testAssertNotIdenticalWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                    "\(AK.notIdentical.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let object1 = TestError() as AnyObject
        
        let object2: () throws -> AnyObject = { try TestError.throwError() }
        
        XCTKAssertNotIdentical(object1, try object2())
    }
    
    
    
    func testAssertEqualFloatAccFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.equalWithAccuracy.name) failed"
            )
        }
        
        XCTKAssertEqual(0.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertEqualFloatAccFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.equalWithAccuracy.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertEqual(0.0, 1.0, accuracy: 0.0, message)
    }
    
    
    
    func testAssertEqualFloatAccWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.equalWithAccuracy.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Double = { try TestError.throwError() }
        
        XCTKAssertEqual(1.0, try expr(), accuracy: 1.0)
    }
    
    
    
    func testAssertEqualIntAccFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.equalWithAccuracy.name) failed"
            )
        }
        
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        XCTKAssertEqual(expr1, expr2, accuracy: 0)
    }
    
    
    
    func testAssertEqualIntAccFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.equalWithAccuracy.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        XCTKAssertEqual(expr1, expr2, accuracy: 0, message)
    }
    
    
    
    func testAssertEqualIntAccWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.equalWithAccuracy.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr1: Int = 1
        
        let expr2: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertEqual(expr1, try expr2(), accuracy: 1)
    }
    
    
    
    func testAssertNotEqualFloatAccFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqualWithAccuracy.name) failed"
            )
        }
        
        XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0)
    }
    
    
    
    func testAssertNotEqualFloatAccFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqualWithAccuracy.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0, message)
    }
    
    
    
    func testAssertNotEqualFloatAccWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqualWithAccuracy.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Double = { try TestError.throwError() }
        
        XCTKAssertNotEqual(1.0, try expr(), accuracy: 1.0)
    }
    
    
    
    func testAssertNotEqualIntAccFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqualWithAccuracy.name) failed"
            )
        }
        
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        XCTKAssertNotEqual(expr1, expr2, accuracy: 1)
    }
    
    
    
    func testAssertNotEqualIntAccFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqualWithAccuracy.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        XCTKAssertNotEqual(expr1, expr2, accuracy: 1, message)
    }
    
    
    
    func testAssertNotEqualIntAccWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notEqualWithAccuracy.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr1: Int = 1
        
        let expr2: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertNotEqual(expr1, try expr2(), accuracy: 1)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThan.name) failed"
            )
        }
        
        XCTKAssertGreaterThan(0, 1)
    }
    
    
    
    func testAssertGreaterFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThan.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertGreaterThan(0, 1, message)
    }
    
    
    
    func testAssertGreaterWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThan.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertGreaterThan(1, try expr())
    }
    
    
    
    func testAssertGreaterEqualFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThanOrEqual.name) failed"
            )
        }
        
        XCTKAssertGreaterThanOrEqual(0, 1)
    }
    
    
    
    func testAssertGreaterEqualFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThanOrEqual.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertGreaterThanOrEqual(0, 1, message)
    }
    
    
    
    func testAssertGreaterEqualWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThanOrEqual.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertGreaterThanOrEqual(1, try expr())
    }
    
    
    
    func testAssertLessEqualFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThanOrEqual.name) failed"
            )
        }
        
        XCTKAssertLessThanOrEqual(1, 0)
    }
    
    
    
    func testAssertLessEqualFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThanOrEqual.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertLessThanOrEqual(1, 0, message)
    }
    
    
    
    func testAssertLessEqualWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThanOrEqual.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertLessThanOrEqual(1, try expr())
    }
    
    
    
    func testAssertLessFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThan.name) failed"
            )
        }
        
        XCTKAssertLessThan(1, 0)
    }
    
    
    
    func testAssertLessFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThan.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertLessThan(1, 0, message)
    }
    
    
    
    func testAssertLessWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThan.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertLessThan(1, try expr())
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.throwsError.name) failed"
            )
        }
        
        XCTKAssertThrowsError({ })
    }
    
    
    
    func testAssertThrowsFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.throwsError.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertThrowsError({ }, message)
    }
    
    
    
    func testAssertNoThrowFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.noThrow.name) failed"
            )
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertNoThrow(try expr())
    }
    
    
    
    func testAssertNoThrowFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.noThrow.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertNoThrow(try expr(), message)
    }
    
    
    
    // MARK: - Fail
    
    func testFailFailureFormat() throws
    {
        XCTExpectFailure
        {
            return !$0.compactDescription.contains(AK.fail.name)
        }
        
        XCTKFail()
    }
    
    
    
    func testFailFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(message)
        }
        
        XCTKFail(message)
    }
}
