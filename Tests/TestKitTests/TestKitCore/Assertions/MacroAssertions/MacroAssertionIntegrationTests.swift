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
@testable import XCTestKit



internal final class MacroAssertionIntegrationTests: TestKitCase
{
    // MARK: - Boolean
    
    func testAssertWithTrueExpr()
    {
        #XCTKAssert(true)
        #XCTKAssert(1 == 1)
        #XCTKAssert(!false)
    }
    
    
    
    func testAssertWithFalseExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssert(false)
        }
    }
    
    
    
    func testAssertTrueWithTrueExpr()
    {
        #XCTKAssertTrue(true)
        #XCTKAssertTrue(1 == 1)
        #XCTKAssertTrue(!false)
    }
    
    
    
    func testAssertTrueWithFalseExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertTrue(false)
        }
    }
    
    
    
    func testAssertFalseWithFalseExpr()
    {
        #XCTKAssertFalse(!true)
        #XCTKAssertFalse(1 != 1)
        #XCTKAssertFalse(false)
    }
    
    
    
    func testAssertFalseWithTrueExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertFalse(true)
        }
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilWithNilExpr()
    {
        #XCTKAssertNil(nil)
        #XCTKAssertNil(Optional<Int>(nil))
    }
    
    
    
    func testAssertNilWithNonNilExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertNil(false)
        }
    }
    
    
    
    func testAssertNotNilWithNonNilExpr()
    {
        #XCTKAssertNotNil(true)
        #XCTKAssertNotNil(false)
        #XCTKAssertNotNil(0)
    }
    
    
    
    func testAssertNotNilWithNilExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertNotNil(nil)
        }
    }
    
    
    
    func testUnwrapWithNilExpr() throws
    {
        withOneExpectedFailure
        {
            _ = try #XCTKUnwrap(Optional<Int>(nil))
        }
    }
    
    
    
    func testUnwrapWithNonNilExpr()
    {
        XCTAssertTrue(try #XCTKUnwrap(true))
        XCTAssertFalse(try #XCTKUnwrap(false))
        XCTAssertNotNil(try #XCTKUnwrap(Optional<Int>(1)))
    }
    
    
    
    func testUnwrapThrowsUnwrapErrorOnNil()
    {
        withOneExpectedFailure
        {
            do
            {
                _ = try #XCTKUnwrap(Optional<Int>(nil))
                
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
    
    func testAssertEqualWithEqualExpr()
    {
        #XCTKAssertEqual(1, 1)
        #XCTKAssertEqual(String("hello"), String("hello"))
    }
    
    
    
    func testAssertEqualWithUnequalExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertEqual(0, 1)
        }
    }
    
    
    
    func testAssertNotEqualWithUnequalExpr()
    {
        #XCTKAssertNotEqual(0, 1)
        #XCTKAssertNotEqual(String("hello"), String("goodbye"))
    }
    
    
    
    func testAssertNotEqualWithEqualExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertNotEqual(1, 1)
        }
    }
    
    
    
    func testAssertIdenticalWithIdenticalExpr()
    {
        let object = TestError() as AnyObject
        
        #XCTKAssertIdentical(object, object)
    }
    
    
    
    func testAssertIdenticalWithUnidenticalExpr()
    {
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        withOneExpectedFailure
        {
            #XCTKAssertIdentical(object1, object2)
        }
    }
    
    
    
    func testAssertNotIdenticalWithUnidenticalExpr()
    {
        let object1     = TestError() as AnyObject
        let object2     = TestError() as AnyObject
        
        #XCTKAssertNotIdentical(object1, object2)
    }
    
    
    
    func testAssertNotIdenticalWithIdenticalExpr()
    {
        let object = TestError() as AnyObject
        
        withOneExpectedFailure
        {
            #XCTKAssertNotIdentical(object, object)
        }
    }
    
    
    
    func testAssertEqualFloatAccWithEqualExpr()
    {
        #XCTKAssertEqual(0.0, 0.0, accuracy: 1.0)
        #XCTKAssertEqual(1.0, 0.0, accuracy: 1.0)
        #XCTKAssertEqual(1.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertEqualFloatAccWithUnequalExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertEqual(0.0, 1.0, accuracy: 0.5)
        }
    }
    
    
    
    func testAssertEqualIntAccWithEqualExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        #XCTKAssertEqual(expr1, expr1, accuracy: 1)
        #XCTKAssertEqual(expr2, expr1, accuracy: 1)
        #XCTKAssertEqual(expr2, expr2, accuracy: 0)
    }
    
    
    
    func testAssertEqualIntAccWithUnequalExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        withOneExpectedFailure
        {
            #XCTKAssertEqual(expr1, expr2, accuracy: 1)
        }
    }
    
    
    
    func testAssertNotEqualFloatAccWithUnequalExpr()
    {
        #XCTKAssertNotEqual(0.0, 2.0, accuracy: 1.0)
        #XCTKAssertNotEqual(1.0, 0.0, accuracy: 0.5)
        #XCTKAssertNotEqual(0.0, 1.0, accuracy: 0.0)
    }
    
    
    
    func testAssertNotEqualFloatAccWithEqualExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0)
        }
    }
    
    
    
    func testAssertNotEqualIntAccWithUnequalExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 2
        
        #XCTKAssertNotEqual(expr1, expr2, accuracy: 0)
        #XCTKAssertNotEqual(expr2, expr1, accuracy: 1)
    }
    
    
    
    func testAssertNotEqualIntAccWithEqualExpr()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        withOneExpectedFailure
        {
            #XCTKAssertNotEqual(expr1, expr2, accuracy: 1)
        }
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterWithTrueExpr()
    {
        #XCTKAssertGreaterThan(1, 0)
        #XCTKAssertGreaterThan(0, -1)
        #XCTKAssertGreaterThan(2.0, 1.0)
    }
    
    
    
    func testAssertGreaterWithFalseExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertGreaterThan(1, 1)
        }
    }
    
    
    
    func testAssertGreaterEqualWithTrueExpr()
    {
        #XCTKAssertGreaterThanOrEqual(1, 0)
        #XCTKAssertGreaterThanOrEqual(0, -1)
        #XCTKAssertGreaterThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertGreaterEqualWithFalseExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertGreaterThanOrEqual(0, 1)
        }
    }
    
    
    
    func testAssertLessEqualWithTrueExpr()
    {
        #XCTKAssertLessThanOrEqual(0, 1)
        #XCTKAssertLessThanOrEqual(-1, 0)
        #XCTKAssertLessThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertLessEqualWithFalseExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertLessThanOrEqual(1, 0)
        }
    }
    
    
    
    func testAssertLessWithTrueExpr()
    {
        #XCTKAssertLessThan(0, 1)
        #XCTKAssertLessThan(-1, 0)
        #XCTKAssertLessThan(1.0, 2.0)
    }
    
    
    
    func testAssertLessWithFalseExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertLessThan(1, 1)
        }
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsWithThrowingExpr()
    {
        let expr: () throws -> Int = { throw TestError() }
        
        #XCTKAssertThrowsError(try expr())
    }
    
    
    
    func testAssertThrowsWithNonThrowingExpr()
    {
        let expr: () throws -> Int = { return 0 }
        
        withOneExpectedFailure
        {
            #XCTKAssertThrowsError(expr)
        }
    }
    
    
    
    func testAssertNoThrowWithNonThrowingExpr()
    {
        let expr: () throws -> Int = { return 0 }
        
        #XCTKAssertNoThrow(expr)
    }
    
    
    
    func testAssertNoThrowWithThrowingExpr()
    {
        let expr: () throws -> Int = { throw TestError() }
        
        withOneExpectedFailure
        {
            #XCTKAssertNoThrow(try expr())
        }
    }
    
    
    
    func testAssertThrowsCallsHandler()
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
    
    
    
    func testAssertThrowsDoesNotCallHandlerOnNoThrow()
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
    
    
    
    func testAssertThrowsHandlerCanAssert()
    {
        let expr: () throws -> Int = { throw TestError() }
        
        #XCTKAssertThrowsError(try expr())
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
            #XCTKFail()
        }
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertAllSatisfyWithPassingExpr()
    {
        #XCTKAssertAllSatisfy([2, 4, 6]) { $0 % 2 == 0 }
        #XCTKAssertAllSatisfy([Int]()) { $0 > 0 }
    }
    
    
    
    func testAssertAllSatisfyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertAllSatisfy([2, 3, 6]) { $0 % 2 == 0 }
        }
    }
    
    
    
    func testAssertAnySatisfyWithPassingExpr()
    {
        #XCTKAssertAnySatisfy([1, 2, 3]) { $0 == 2 }
        #XCTKAssertAnySatisfy([1, 3, 5]) { $0 % 3 == 0 }
    }
    
    
    
    func testAssertAnySatisfyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertAnySatisfy([1, 3, 5]) { $0 % 2 == 0 }
        }
    }
    
    
    
    func testAssertNoneSatisfyWithPassingExpr()
    {
        #XCTKAssertNoneSatisfy([1, 3, 5]) { $0 % 2 == 0 }
        #XCTKAssertNoneSatisfy([Int]()) { $0 > 0 }
    }
    
    
    
    func testAssertNoneSatisfyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertNoneSatisfy([1, 2, 3]) { $0 % 2 == 0 }
        }
    }
    
    
    
    func testAssertSatisfyAtLeastWithPassingExpr()
    {
        #XCTKAssertSatisfy([1, 2, 3, 4], atLeast: 2) { $0 % 2 == 0 }
        #XCTKAssertSatisfy([1, 2, 3, 4], atLeast: 0) { $0 > 10 }
    }
    
    
    
    func testAssertSatisfyAtLeastWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertSatisfy([1, 2, 3, 4], atLeast: 3) { $0 > 2 }
        }
    }
    
    
    
    func testAssertSatisfyAtMostWithPassingExpr()
    {
        #XCTKAssertSatisfy([1, 2, 3, 4], atMost: 2) { $0 > 2 }
        #XCTKAssertSatisfy([1, 2, 3, 4], atMost: 4) { $0 > 0 }
    }
    
    
    
    func testAssertSatisfyAtMostWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertSatisfy([1, 2, 3, 4], atMost: 1) { $0 > 2 }
        }
    }
    
    
    
    func testAssertSatisfyRangeWithPassingExpr()
    {
        #XCTKAssertSatisfy([1, 2, 3, 4, 5], range: 2...3) { $0 > 2 }
        #XCTKAssertSatisfy([1, 2, 3], range: 0...0) { $0 > 10 }
    }
    
    
    
    func testAssertSatisfyRangeWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertSatisfy([1, 2, 3, 4, 5], range: 0...1) { $0 > 2 }
        }
    }
    
    
    
    func testAssertExactlyWithPassingExpr()
    {
        #XCTKAssertExactly([1, 2, 3, 4], count: 2) { $0 > 2 }
        #XCTKAssertExactly([1, 2, 3], count: 0) { $0 > 10 }
    }
    
    
    
    func testAssertExactlyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertExactly([1, 2, 3, 4], count: 3) { $0 > 2 }
        }
    }
    
    
    
    func testAssertExactlyOneWithPassingExpr()
    {
        #XCTKAssertExactlyOne([1, 2, 3]) { $0 == 2 }
        #XCTKAssertExactlyOne([1, 2, 3]) { $0 > 2 }
    }
    
    
    
    func testAssertExactlyOneWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertExactlyOne([1, 2, 3]) { $0 > 1 }
        }
    }
    
    
    
    func testAssertSortedWithPassingExpr()
    {
        #XCTKAssertSorted([1, 2, 3, 4], by: <)
        #XCTKAssertSorted([4, 3, 2, 1], by: >)
        #XCTKAssertSorted([Int](), by: <)
        #XCTKAssertSorted([1], by: <)
    }
    
    
    
    func testAssertSortedWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertSorted([1, 3, 2, 4], by: <)
        }
    }
    
    
    
    func testAssertUniqueWithPassingExpr()
    {
        #XCTKAssertUnique([1, 2, 3, 4])
        #XCTKAssertUnique([Int]())
        #XCTKAssertUnique([1])
    }
    
    
    
    func testAssertUniqueWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertUnique([1, 2, 3, 2])
        }
    }
    
    
    
    func testAssertUniqueByKeyWithPassingExpr()
    {
        #XCTKAssertUnique(["a", "bb", "ccc"], by: { $0.count })
        #XCTKAssertUnique([1, 2, 3], by: { $0 })
        #XCTKAssertUnique([1, 2, 3], by: { $0 * 2 })
    }
    
    
    
    func testAssertUniqueByKeyWithFailingExpr()
    {
        withOneExpectedFailure
        {
            #XCTKAssertUnique(["a", "b", "cc"], by: { $0.count })
        }
    }
}
