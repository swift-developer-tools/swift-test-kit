//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TKTestSupport
import XCTest
@testable import XCTestKit



internal final class MacroAssertionIntegrationTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertWithTrueExpr() throws
    {
        #XCTKAssert(true)
        #XCTKAssert(1 == 1)
        #XCTKAssert(!false)
    }
    
    
    
    func testAssertWithFalseExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssert(false)
    }
    
    
    
    func testAssertTrueWithTrueExpr() throws
    {
        #XCTKAssertTrue(true)
        #XCTKAssertTrue(1 == 1)
        #XCTKAssertTrue(!false)
    }
    
    
    
    func testAssertTrueWithFalseExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertTrue(false)
    }
    
    
    
    func testAssertFalseWithFalseExpr() throws
    {
        #XCTKAssertFalse(!true)
        #XCTKAssertFalse(1 != 1)
        #XCTKAssertFalse(false)
    }
    
    
    
    func testAssertFalseWithTrueExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertFalse(true)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilWithNilExpr() throws
    {
        #XCTKAssertNil(nil)
        #XCTKAssertNil(Optional<Int>(nil))
    }
    
    
    
    func testAssertNilWithNonNilExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertNil(false)
    }
    
    
    
    func testAssertNotNilWithNonNilExpr() throws
    {
        #XCTKAssertNotNil(true)
        #XCTKAssertNotNil(false)
        #XCTKAssertNotNil(0)
    }
    
    
    
    func testAssertNotNilWithNilExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertNotNil(nil)
    }
    
    
    
    func testUnwrapWithNilExpr() throws
    {
        XCTExpectFailure()
        _ = try #XCTKUnwrap(Optional<Int>(nil))
    }
    
    
    
    func testUnwrapWithNonNilExpr() throws
    {
        XCTAssertTrue(try #XCTKUnwrap(true))
        XCTAssertFalse(try #XCTKUnwrap(false))
        XCTAssertNotNil(try #XCTKUnwrap(Optional<Int>(1)))
    }
    
    
    
    func testUnwrapThrowsXCTKUnwrapErrorOnNil() throws
    {
        withOneExpectedFailure
        {
            do
            {
                _ = try #XCTKUnwrap(Optional<Int>(nil))
                
                XCTFail("Expected XCTKUnwrapError to be thrown")
            }
            catch is XCTKUnwrapError
            {
                /// Expected.
            }
            catch
            {
                XCTFail("Expected XCTKUnwrapError, got \(type(of: error))")
            }
        }
    }
    
    
    
    func testUnwrapRethrowsOriginalError() throws
    {
        withOneExpectedFailure
        {
            do
            {
                let expr: () throws -> Bool = { throw TestError() }
                
                _ = try #XCTKUnwrap(try expr())
                
                XCTFail("Expected TestError to be thrown")
            }
            catch is TestError
            {
                /// Expected.
            }
            catch
            {
                XCTFail("Expected TestError, got \(type(of: error))")
            }
        }
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualWithEqualExpr() throws
    {
        #XCTKAssertEqual(1, 1)
        #XCTKAssertEqual(String("hello"), String("hello"))
    }
    
    
    
    func testAssertEqualWithUnequalExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertEqual(0, 1)
    }
    
    
    
    func testAssertNotEqualWithUnequalExpr() throws
    {
        #XCTKAssertNotEqual(0, 1)
        #XCTKAssertNotEqual(String("hello"), String("goodbye"))
    }
    
    
    
    func testAssertNotEqualWithEqualExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertNotEqual(1, 1)
    }
    
    
    
    func testAssertIdenticalWithIdenticalExpr() throws
    {
        let object = TestError() as AnyObject
        
        #XCTKAssertIdentical(object, object)
    }
    
    
    
    func testAssertIdenticalWithUnidenticalExpr() throws
    {
        XCTExpectFailure()

        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        #XCTKAssertIdentical(object1, object2)
    }
    
    
    
    func testAssertNotIdenticalWithUnidenticalExpr() throws
    {
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        #XCTKAssertNotIdentical(object1, object2)
    }
    
    
    
    func testAssertNotIdenticalWithIdenticalExpr() throws
    {
        XCTExpectFailure()
        
        let object = TestError() as AnyObject
        
        #XCTKAssertNotIdentical(object, object)
    }
    
    
    
    func testAssertEqualFloatAccWithEqualExpr() throws
    {
        #XCTKAssertEqual(0.0, 0.0, accuracy: 1.0)
        #XCTKAssertEqual(1.0, 0.0, accuracy: 1.0)
        #XCTKAssertEqual(1.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertEqualFloatAccWithUnequalExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertEqual(0.0, 1.0, accuracy: 0.5)
    }
    
    
    
    func testAssertEqualIntAccWithEqualExpr() throws
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        #XCTKAssertEqual(expr1, expr1, accuracy: 1)
        #XCTKAssertEqual(expr2, expr1, accuracy: 1)
        #XCTKAssertEqual(expr2, expr2, accuracy: 0)
    }
    
    
    
    func testAssertEqualIntAccWithUnequalExpr() throws
    {
        XCTExpectFailure()
        
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        #XCTKAssertEqual(expr1, expr2, accuracy: 1)
    }
    
    
    
    func testAssertNotEqualFloatAccWithUnequalExpr() throws
    {
        #XCTKAssertNotEqual(0.0, 2.0, accuracy: 1.0)
        #XCTKAssertNotEqual(1.0, 0.0, accuracy: 0.5)
        #XCTKAssertNotEqual(0.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertNotEqualFloatAccWithEqualExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0)
    }
    
    
    
    func testAssertNotEqualIntAccWithUnequalExpr() throws
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        #XCTKAssertNotEqual(expr1, expr2, accuracy: 0)
        #XCTKAssertNotEqual(expr2, expr1, accuracy: 1)
    }
    
    
    
    func testAssertNotEqualIntAccWithEqualExpr() throws
    {
        XCTExpectFailure()
        
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        #XCTKAssertNotEqual(expr1, expr2, accuracy: 1)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterWithTrueExpr() throws
    {
        #XCTKAssertGreaterThan(1, 0)
        #XCTKAssertGreaterThan(0, -1)
        #XCTKAssertGreaterThan(2.0, 1.0)
    }
    
    
    
    func testAssertGreaterWithFalseExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertGreaterThan(1, 1)
    }
    
    
    
    func testAssertGreaterEqualWithTrueExpr() throws
    {
        #XCTKAssertGreaterThanOrEqual(1, 0)
        #XCTKAssertGreaterThanOrEqual(0, -1)
        #XCTKAssertGreaterThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertGreaterEqualWithFalseExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertGreaterThanOrEqual(0, 1)
    }
    
    
    
    func testAssertLessEqualWithTrueExpr() throws
    {
        #XCTKAssertLessThanOrEqual(0, 1)
        #XCTKAssertLessThanOrEqual(-1, 0)
        #XCTKAssertLessThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertLessEqualWithFalseExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertLessThanOrEqual(1, 0)
    }
    
    
    
    func testAssertLessWithTrueExpr() throws
    {
        #XCTKAssertLessThan(0, 1)
        #XCTKAssertLessThan(-1, 0)
        #XCTKAssertLessThan(1.0, 2.0)
    }
    
    
    
    func testAssertLessWithFalseExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertLessThan(1, 1)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsWithThrowingExpr() throws
    {
        let expr: () throws -> Int = { throw TestError() }
        
        #XCTKAssertThrowsError(try expr())
    }
    
    
    
    func testAssertThrowsWithNonThrowingExpr() throws
    {
        let expr: () throws -> Int = { return 0 }
        
        XCTExpectFailure()
        #XCTKAssertThrowsError(expr)
    }
    
    
    
    func testAssertNoThrowWithNonThrowingExpr() throws
    {
        let expr: () throws -> Int = { return 0 }
        
        #XCTKAssertNoThrow(expr)
    }
    
    
    
    func testAssertNoThrowWithThrowingExpr() throws
    {
        XCTExpectFailure()

        let expr: () throws -> Int = { throw TestError() }
        
        #XCTKAssertNoThrow(try expr())
    }
    
    
    
    func testAssertThrowsCallsHandler() throws
    {
        var handlerCalled: Bool = false
        
        let expr: () throws -> Int = { throw TestError() }
        
        #XCTKAssertThrowsError(try expr())
        {
            _ in
            
            handlerCalled = true
        }
        
        XCTAssertTrue(handlerCalled)
    }
    
    
    
    func testAssertThrowsDoesNotCallHandlerOnNoThrow() throws
    {
        var handlerCalled: Bool = false
        
        let expr: () throws -> Int = { return 0 }
        
        withOneExpectedFailure
        {
            #XCTKAssertThrowsError(try expr())
            {
                _ in
                
                handlerCalled = true
            }
            
            XCTAssertFalse(handlerCalled)
        }
    }
    
    
    
    func testAssertThrowsHandlerReceivesErrorWithData() throws
    {
        enum SomeError: Error, Equatable
        {
            case invalid(
                _ code:     Int,
                _ domain:   String
            )
        }
        
        let error   : SomeError         = .invalid(10, "a")
        let expr    : () throws -> Int  = { throw error }
        
        #XCTKAssertThrowsError(try expr())
        {
            guard let someError = $0 as? SomeError
            else
            {
                XCTFail("Expected SomeError, got \(type(of: $0))")
                return
            }
            
            XCTAssertEqual(someError, error)
        }
    }
    
    
    
    func testAssertThrowsHandlerCanAssert() throws
    {
        let expr: () throws -> Int = { throw TestError() }
        
        #XCTKAssertThrowsError(try expr())
        {
            error in
            
            XCTAssertTrue(error is TestError)
        }
    }
    
    
    
    // MARK: - Fail
    
    func testFail() throws
    {
        XCTExpectFailure()
        #XCTKFail()
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertAllSatisfyWithPassingExpr() throws
    {
        #XCTKAssertAllSatisfy([2, 4, 6]) { $0 % 2 == 0 }
        #XCTKAssertAllSatisfy([Int]()) { $0 > 0 }
    }
    
    
    
    func testAssertAllSatisfyWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertAllSatisfy([2, 3, 6]) { $0 % 2 == 0 }
    }
    
    
    
    func testAssertAnySatisfyWithPassingExpr() throws
    {
        #XCTKAssertAnySatisfy([1, 2, 3]) { $0 == 2 }
        #XCTKAssertAnySatisfy([1, 3, 5]) { $0 % 3 == 0 }
    }
    
    
    
    func testAssertAnySatisfyWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertAnySatisfy([1, 3, 5]) { $0 % 2 == 0 }
    }
    
    
    
    func testAssertNoneSatisfyWithPassingExpr() throws
    {
        #XCTKAssertNoneSatisfy([1, 3, 5]) { $0 % 2 == 0 }
        #XCTKAssertNoneSatisfy([Int]()) { $0 > 0 }
    }
    
    
    
    func testAssertNoneSatisfyWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertNoneSatisfy([1, 2, 3]) { $0 % 2 == 0 }
    }
    
    
    
    func testAssertSatisfyAtLeastWithPassingExpr() throws
    {
        #XCTKAssertSatisfy([1, 2, 3, 4], atLeast: 2) { $0 % 2 == 0 }
        #XCTKAssertSatisfy([1, 2, 3, 4], atLeast: 0) { $0 > 10 }
    }
    
    
    
    func testAssertSatisfyAtLeastWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertSatisfy([1, 2, 3, 4], atLeast: 3) { $0 > 2 }
    }
    
    
    
    func testAssertSatisfyAtMostWithPassingExpr() throws
    {
        #XCTKAssertSatisfy([1, 2, 3, 4], atMost: 2) { $0 > 2 }
        #XCTKAssertSatisfy([1, 2, 3, 4], atMost: 4) { $0 > 0 }
    }
    
    
    
    func testAssertSatisfyAtMostWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertSatisfy([1, 2, 3, 4], atMost: 1) { $0 > 2 }
    }
    
    
    
    func testAssertSatisfyRangeWithPassingExpr() throws
    {
        #XCTKAssertSatisfy([1, 2, 3, 4, 5], range: 2...3) { $0 > 2 }
        #XCTKAssertSatisfy([1, 2, 3], range: 0...0) { $0 > 10 }
    }
    
    
    
    func testAssertSatisfyRangeWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertSatisfy([1, 2, 3, 4, 5], range: 0...1) { $0 > 2 }
    }
    
    
    
    func testAssertExactlyWithPassingExpr() throws
    {
        #XCTKAssertExactly([1, 2, 3, 4], count: 2) { $0 > 2 }
        #XCTKAssertExactly([1, 2, 3], count: 0) { $0 > 10 }
    }
    
    
    
    func testAssertExactlyWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertExactly([1, 2, 3, 4], count: 3) { $0 > 2 }
    }
    
    
    
    func testAssertExactlyOneWithPassingExpr() throws
    {
        #XCTKAssertExactlyOne([1, 2, 3]) { $0 == 2 }
        #XCTKAssertExactlyOne([1, 2, 3]) { $0 > 2 }
    }
    
    
    
    func testAssertExactlyOneWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertExactlyOne([1, 2, 3]) { $0 > 1 }
    }
    
    
    
    func testAssertSortedWithPassingExpr() throws
    {
        #XCTKAssertSorted([1, 2, 3, 4], by: <)
        #XCTKAssertSorted([4, 3, 2, 1], by: >)
        #XCTKAssertSorted([Int](), by: <)
        #XCTKAssertSorted([1], by: <)
    }
    
    
    
    func testAssertSortedWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertSorted([1, 3, 2, 4], by: <)
    }
    
    
    
    func testAssertUniqueWithPassingExpr() throws
    {
        #XCTKAssertUnique([1, 2, 3, 4])
        #XCTKAssertUnique([Int]())
        #XCTKAssertUnique([1])
    }
    
    
    
    func testAssertUniqueWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertUnique([1, 2, 3, 2])
    }
    
    
    
    func testAssertUniqueByKeyWithPassingExpr() throws
    {
        #XCTKAssertUnique(["a", "bb", "ccc"], by: { $0.count })
        #XCTKAssertUnique([1, 2, 3], by: { $0 })
        #XCTKAssertUnique([1, 2, 3], by: { $0 * 2 })
    }
    
    
    
    func testAssertUniqueByKeyWithFailingExpr() throws
    {
        XCTExpectFailure()
        #XCTKAssertUnique(["a", "b", "cc"], by: { $0.count })
    }
}
