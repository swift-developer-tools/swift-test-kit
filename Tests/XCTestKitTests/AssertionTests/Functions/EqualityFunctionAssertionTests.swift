//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit
@testable import XCTestKitTestUtilities



final class EqualityFunctionAssertionTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    // MARK: - Equal
    
    func testAssertEqualWithEqualExpr() throws
    {
        XCTKAssertEqual(1, 1)
        XCTKAssertEqual(String("hello"), String("hello"))
    }
    
    
    
    func testAssertEqualWithUnequalExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertEqual(0, 1)
    }
    
    
    
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
    
    
    
    func testAssertEqualMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.equal)
    }
    
    
    
    // MARK: - Not equal
    
    func testAssertNotEqualWithUnequalExpr() throws
    {
        XCTKAssertNotEqual(0, 1)
        XCTKAssertNotEqual(String("hello"), String("goodbye"))
    }
    
    
    
    func testAssertNotEqualWithEqualExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertNotEqual(1, 1)
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
    
    
    
    func testAssertNotEqualMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.notEqual)
    }
    
    
    
    // MARK: - Identical
    
    func testAssertIdenticalWithIdenticalExpr() throws
    {
        let object = TestError() as AnyObject
        
        XCTKAssertIdentical(object, object)
    }
    
    
    
    func testAssertIdenticalWithUnidenticalExpr() throws
    {
        XCTExpectFailure()

        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        XCTKAssertIdentical(object1, object2)
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
    
    
    
    func testAssertIdenticalMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.identical)
    }
    
    
    
    // MARK: - Not identical
    
    func testAssertNotIdenticalWithUnidenticalExpr() throws
    {
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        XCTKAssertNotIdentical(object1, object2)
    }
    
    
    
    func testAssertNotIdenticalWithIdenticalExpr() throws
    {
        XCTExpectFailure()
        
        let object = TestError() as AnyObject
        
        XCTKAssertNotIdentical(object, object)
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
    
    
    
    func testAssertNotIdenticalMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.notIdentical)
    }
    
    
    
    // MARK: - Equal accuracy float
    
    func testAssertEqualFloatAccWithEqualExpr() throws
    {
        XCTKAssertEqual(0.0, 0.0, accuracy: 1.0)
        XCTKAssertEqual(1.0, 0.0, accuracy: 1.0)
        XCTKAssertEqual(1.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertEqualFloatAccWithUnequalExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertEqual(0.0, 1.0, accuracy: 0.5)
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
    
    
    
    func testAssertEqualFloatAccMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    // MARK: - Equal accuracy numeric
    
    func testAssertEqualIntAccWithEqualExpr() throws
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        XCTKAssertEqual(expr1, expr1, accuracy: 1)
        XCTKAssertEqual(expr2, expr1, accuracy: 1)
        XCTKAssertEqual(expr2, expr2, accuracy: 0)
    }
    
    
    
    func testAssertEqualIntAccWithUnequalExpr() throws
    {
        XCTExpectFailure()
        
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        XCTKAssertEqual(expr1, expr2, accuracy: 1)
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
    
    
    
    func testAssertEqualIntAccMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Not equal accuracy float
    
    func testAssertNotEqualFloatAccWithUnequalExpr() throws
    {
        XCTKAssertNotEqual(0.0, 2.0, accuracy: 1.0)
        XCTKAssertNotEqual(1.0, 0.0, accuracy: 0.5)
        XCTKAssertNotEqual(0.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertNotEqualFloatAccWithEqualExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0)
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
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    // MARK: - Not equal accuracy numeric
    
    func testAssertNotEqualIntAccWithUnequalExpr() throws
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        XCTKAssertNotEqual(expr1, expr2, accuracy: 0)
        XCTKAssertNotEqual(expr2, expr1, accuracy: 1)
    }
    
    
    
    func testAssertNotEqualIntAccWithEqualExpr() throws
    {
        XCTExpectFailure()
        
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        XCTKAssertNotEqual(expr1, expr2, accuracy: 1)
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
    
    
    
    func testAssertNotEqualIntAccMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
}
