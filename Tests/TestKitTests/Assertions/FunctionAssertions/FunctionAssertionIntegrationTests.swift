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



internal final class FunctionAssertionIntegrationTests: TestKitCase
{
    // MARK: - Boolean
    
    func testAssertWithTrueExpr()
    {
        TKAssert(true)
        TKAssert(1 == 1)
        TKAssert(!false)
    }
    
    
    
    func testAssertWithFalseExpr()
    {
        withOneExpectedFailure
        {
            TKAssert(false)
        }
    }
    
    
    
    func testAssertTrueWithTrueExpr()
    {
        TKAssertTrue(true)
        TKAssertTrue(1 == 1)
        TKAssertTrue(!false)
    }
    
    
    
    func testAssertTrueWithFalseExpr()
    {
        withOneExpectedFailure
        {
            TKAssertTrue(false)
        }
    }
    
    
    
    func testAssertFalseWithFalseExpr()
    {
        TKAssertFalse(!true)
        TKAssertFalse(1 != 1)
        TKAssertFalse(false)
    }
    
    
    
    func testAssertFalseWithTrueExpr()
    {
        withOneExpectedFailure
        {
            TKAssertFalse(true)
        }
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilWithNilExpr()
    {
        TKAssertNil(nil)
        TKAssertNil(Optional<Int>(nil))
    }
    
    
    
    func testAssertNilWithNonNilExpr()
    {
        withOneExpectedFailure
        {
            TKAssertNil(false)
        }
    }
    
    
    
    func testAssertNotNilWithNonNilExpr()
    {
        TKAssertNotNil(true)
        TKAssertNotNil(false)
        TKAssertNotNil(0)
    }
    
    
    
    func testAssertNotNilWithNilExpr()
    {
        withOneExpectedFailure
        {
            TKAssertNotNil(nil)
        }
    }
    
    
    
    func testUnwrapWithNilExpr() throws
    {
        withOneExpectedFailure
        {
            _ = try TKUnwrap(Optional<Int>(nil))
        }
    }
    
    
    
    func testUnwrapWithNonNilExpr()
    {
        XCTAssertTrue(try TKUnwrap(true))
        XCTAssertFalse(try TKUnwrap(false))
        XCTAssertNotNil(try TKUnwrap(Optional<Int>(1)))
    }
    
    
    
    func testUnwrapThrowsUnwrapErrorOnNil()
    {
        withOneExpectedFailure
        {
            do
            {
                _ = try TKUnwrap(Optional<Int>(nil))
                
                XCTFail("Expected UnwrapError to be thrown")
            }
            catch is UnwrapError
            {
                /// Expected.
            }
            catch
            {
                XCTFail("Expected UnwrapError, got \(type(of: error))")
            }
        }
    }
    
    
    
    func testUnwrapRethrowsOriginalError()
    {
        withOneExpectedFailure
        {
            do
            {
                let expr: () throws -> Bool = { throw TestError() }
                
                _ = try TKUnwrap(try expr())
                
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
    
    func testAssertEqualWithEqualExpr()
    {
        TKAssertEqual(1, 1)
        TKAssertEqual(String("hello"), String("hello"))
    }
    
    
    
    func testAssertEqualWithUnequalExpr()
    {
        withOneExpectedFailure
        {
            TKAssertEqual(0, 1)
        }
    }
    
    
    
    func testAssertNotEqualWithUnequalExpr()
    {
        TKAssertNotEqual(0, 1)
        TKAssertNotEqual(String("hello"), String("goodbye"))
    }
    
    
    
    func testAssertNotEqualWithEqualExpr()
    {
        withOneExpectedFailure
        {
            TKAssertNotEqual(1, 1)
        }
    }
    
    
    
    func testAssertIdenticalWithIdenticalExpr()
    {
        let object = TestError() as AnyObject
        
        TKAssertIdentical(object, object)
    }
    
    
    
    func testAssertIdenticalWithUnidenticalExpr()
    {
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        withOneExpectedFailure
        {
            TKAssertIdentical(object1, object2)
        }
    }
    
    
    
    func testAssertNotIdenticalWithUnidenticalExpr()
    {
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        TKAssertNotIdentical(object1, object2)
    }
    
    
    
    func testAssertNotIdenticalWithIdenticalExpr()
    {
        let object = TestError() as AnyObject
        
        withOneExpectedFailure
        {
            TKAssertNotIdentical(object, object)
        }
    }
    
    
    
    func testAssertEqualFloatAccWithEqualExpr()
    {
        TKAssertEqual(0.0, 0.0, accuracy: 1.0)
        TKAssertEqual(1.0, 0.0, accuracy: 1.0)
        TKAssertEqual(1.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertEqualFloatAccWithUnequalExpr()
    {
        withOneExpectedFailure
        {
            TKAssertEqual(0.0, 1.0, accuracy: 0.5)
        }
    }
    
    
    
    func testAssertEqualIntAccWithEqualExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        TKAssertEqual(expr1, expr1, accuracy: 1)
        TKAssertEqual(expr2, expr1, accuracy: 1)
        TKAssertEqual(expr2, expr2, accuracy: 0)
    }
    
    
    
    func testAssertEqualIntAccWithUnequalExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        withOneExpectedFailure
        {
            TKAssertEqual(expr1, expr2, accuracy: 1)
        }
    }
    
    
    
    func testAssertNotEqualFloatAccWithUnequalExpr()
    {
        TKAssertNotEqual(0.0, 2.0, accuracy: 1.0)
        TKAssertNotEqual(1.0, 0.0, accuracy: 0.5)
        TKAssertNotEqual(0.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertNotEqualFloatAccWithEqualExpr()
    {
        withOneExpectedFailure
        {
            TKAssertNotEqual(0.0, 1.0, accuracy: 1.0)
        }
    }
    
    
    
    func testAssertNotEqualIntAccWithUnequalExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        TKAssertNotEqual(expr1, expr2, accuracy: 0)
        TKAssertNotEqual(expr2, expr1, accuracy: 1)
    }
    
    
    
    func testAssertNotEqualIntAccWithEqualExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        withOneExpectedFailure
        {
            TKAssertNotEqual(expr1, expr2, accuracy: 1)
        }
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterWithTrueExpr()
    {
        TKAssertGreaterThan(1, 0)
        TKAssertGreaterThan(0, -1)
        TKAssertGreaterThan(2.0, 1.0)
    }
    
    
    
    func testAssertGreaterWithFalseExpr()
    {
        withOneExpectedFailure
        {
            TKAssertGreaterThan(1, 1)
        }
    }
    
    
    
    func testAssertGreaterEqualWithTrueExpr()
    {
        TKAssertGreaterThanOrEqual(1, 0)
        TKAssertGreaterThanOrEqual(0, -1)
        TKAssertGreaterThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertGreaterEqualWithFalseExpr()
    {
        withOneExpectedFailure
        {
            TKAssertGreaterThanOrEqual(0, 1)
        }
    }
    
    
    
    func testAssertLessEqualWithTrueExpr()
    {
        TKAssertLessThanOrEqual(0, 1)
        TKAssertLessThanOrEqual(-1, 0)
        TKAssertLessThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertLessEqualWithFalseExpr()
    {
        withOneExpectedFailure
        {
            TKAssertLessThanOrEqual(1, 0)
        }
    }
    
    
    
    func testAssertLessWithTrueExpr()
    {
        TKAssertLessThan(0, 1)
        TKAssertLessThan(-1, 0)
        TKAssertLessThan(1.0, 2.0)
    }
    
    
    
    func testAssertLessWithFalseExpr()
    {
        withOneExpectedFailure
        {
            TKAssertLessThan(1, 1)
        }
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsWithThrowingExpr()
    {
        let expr: () throws -> Int = { throw TestError() }
        
        TKAssertThrowsError(try expr())
    }
    
    
    
    func testAssertThrowsWithNonThrowingExpr()
    {
        let expr: () throws -> Int = { return 0 }
        
        withOneExpectedFailure
        {
            TKAssertThrowsError(expr)
        }
    }
    
    
    
    func testAssertNoThrowWithNonThrowingExpr()
    {
        let expr: () throws -> Int = { return 0 }
        
        TKAssertNoThrow(expr)
    }
    
    
    
    func testAssertNoThrowWithThrowingExpr()
    {
        let expr: () throws -> Int = { throw TestError() }
        
        withOneExpectedFailure
        {
            TKAssertNoThrow(try expr())
        }
    }
    
    
    
    func testAssertThrowsCallsHandler()
    {
        var handlerCalled: Bool = false
        
        let expr: () throws -> Int = { throw TestError() }
        
        TKAssertThrowsError(try expr())
        {
            _ in
            
            handlerCalled = true
        }
        
        XCTAssertTrue(handlerCalled)
    }
    
    
    
    func testAssertThrowsDoesNotCallHandlerOnNoThrow()
    {
        var handlerCalled: Bool = false
        
        let expr: () throws -> Int = { return 0 }
        
        withOneExpectedFailure
        {
            TKAssertThrowsError(try expr())
            {
                _ in
                
                handlerCalled = true
            }
            
            XCTAssertFalse(handlerCalled)
        }
    }
    
    
    
    func testAssertThrowsHandlerReceivesErrorWithData()
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
        
        TKAssertThrowsError(try expr())
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
    
    
    
    func testAssertThrowsHandlerCanAssert()
    {
        let expr: () throws -> Int = { throw TestError() }
        
        TKAssertThrowsError(try expr())
        {
            error in
            
            XCTAssertTrue(error is TestError)
        }
    }
    
    
    
    // MARK: - Fail
    
    func testFail()
    {
        withOneExpectedFailure
        {
            TKFail()
        }
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertAllSatisfyWithPassingExpr()
    {
        TKAssertAllSatisfy([2, 4, 6]) { $0 % 2 == 0 }
        TKAssertAllSatisfy([Int]()) { $0 > 0 }
    }
    
    
    
    func testAssertAllSatisfyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertAllSatisfy([2, 3, 6]) { $0 % 2 == 0 }
        }
    }
    
    
    
    func testAssertAnySatisfyWithPassingExpr()
    {
        TKAssertAnySatisfy([1, 2, 3]) { $0 == 2 }
        TKAssertAnySatisfy([1, 3, 5]) { $0 % 3 == 0 }
    }
    
    
    
    func testAssertAnySatisfyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertAnySatisfy([1, 3, 5]) { $0 % 2 == 0 }
        }
    }
    
    
    
    func testAssertNoneSatisfyWithPassingExpr()
    {
        TKAssertNoneSatisfy([1, 3, 5]) { $0 % 2 == 0 }
        TKAssertNoneSatisfy([Int]()) { $0 > 0 }
    }
    
    
    
    func testAssertNoneSatisfyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertNoneSatisfy([1, 2, 3]) { $0 % 2 == 0 }
        }
    }
    
    
    
    func testAssertSatisfyAtLeastWithPassingExpr()
    {
        TKAssertSatisfy([1, 2, 3, 4], atLeast: 2) { $0 % 2 == 0 }
        TKAssertSatisfy([1, 2, 3, 4], atLeast: 0) { $0 > 10 }
    }
    
    
    
    func testAssertSatisfyAtLeastWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertSatisfy([1, 2, 3, 4], atLeast: 3) { $0 > 2 }
        }
    }
    
    
    
    func testAssertSatisfyAtMostWithPassingExpr()
    {
        TKAssertSatisfy([1, 2, 3, 4], atMost: 2) { $0 > 2 }
        TKAssertSatisfy([1, 2, 3, 4], atMost: 4) { $0 > 0 }
    }
    
    
    
    func testAssertSatisfyAtMostWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertSatisfy([1, 2, 3, 4], atMost: 1) { $0 > 2 }
        }
    }
    
    
    
    func testAssertSatisfyRangeWithPassingExpr()
    {
        TKAssertSatisfy([1, 2, 3, 4, 5], range: 2...3) { $0 > 2 }
        TKAssertSatisfy([1, 2, 3], range: 0...0) { $0 > 10 }
    }
    
    
    
    func testAssertSatisfyRangeWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertSatisfy([1, 2, 3, 4, 5], range: 0...1) { $0 > 2 }
        }
    }
    
    
    
    func testAssertExactlyWithPassingExpr()
    {
        TKAssertExactly([1, 2, 3, 4], count: 2) { $0 > 2 }
        TKAssertExactly([1, 2, 3], count: 0) { $0 > 10 }
    }
    
    
    
    func testAssertExactlyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertExactly([1, 2, 3, 4], count: 3) { $0 > 2 }
        }
    }
    
    
    
    func testAssertExactlyOneWithPassingExpr()
    {
        TKAssertExactlyOne([1, 2, 3]) { $0 == 2 }
        TKAssertExactlyOne([1, 2, 3]) { $0 > 2 }
    }
    
    
    
    func testAssertExactlyOneWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertExactlyOne([1, 2, 3]) { $0 > 1 }
        }
    }
    
    
    
    func testAssertSortedWithPassingExpr()
    {
        TKAssertSorted([1, 2, 3, 4], by: <)
        TKAssertSorted([4, 3, 2, 1], by: >)
        TKAssertSorted([Int](), by: <)
        TKAssertSorted([1], by: <)
    }
    
    
    
    func testAssertSortedWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertSorted([1, 3, 2, 4], by: <)
        }
    }
    
    
    
    func testAssertUniqueWithPassingExpr()
    {
        TKAssertUnique([1, 2, 3, 4])
        TKAssertUnique([Int]())
        TKAssertUnique([1])
    }
    
    
    
    func testAssertUniqueWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertUnique([1, 2, 3, 2])
        }
    }
    
    
    
    func testAssertUniqueByKeyWithPassingExpr()
    {
        TKAssertUnique(["a", "bb", "ccc"], by: { $0.count })
        TKAssertUnique([1, 2, 3], by: { $0 })
        TKAssertUnique([1, 2, 3], by: { $0 * 2 })
    }
    
    
    
    func testAssertUniqueByKeyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            TKAssertUnique(["a", "b", "cc"], by: { $0.count })
        }
    }
}
