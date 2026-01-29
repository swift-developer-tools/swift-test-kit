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



// MARK: - Functions

/// Asserts that the message of the specified assertion is not evaluated
/// when the assertion succeeds.
///
/// - Note: This does nothing for ``AssertionKind/fail``.
///
/// - Parameters:
///   - kind: The assertion to use.
///   - useFloats: Whether to use floating-point numbers when testing for
///   equality with accuracy. Otherwise, integers will be used.
internal func testFunctionAssertionMessageNotEvalOnSuccess(
    _ kind      : AssertionKind,
    useFloats   : Bool          = false
)
{
    var count   : Int           = 0
    let message : () -> String  = { count += 1; return "msg" }
    
    switch kind
    {
        case .assert:
            
            XCTKAssert(true, message())
            
        case .equal:
            
            XCTKAssertEqual(1, 1, message())
            
        case .notEqual:
            
            XCTKAssertNotEqual(0, 1, message())
            
        case .equalWithAccuracy:
            
            if useFloats
            {
                XCTKAssertEqual(1.0, 1.0, accuracy: 0.5, message())
            }
            else
            {
                let expr1   : Int   = 1
                let expr2   : Int   = 1
                
                XCTKAssertEqual(expr1, expr2, accuracy: 1, message())
            }
            
        case .notEqualWithAccuracy:
            
            if useFloats
            {
                XCTKAssertNotEqual(0.0, 1.0, accuracy: 0.0, message())
            }
            else
            {
                let expr1   : Int   = 0
                let expr2   : Int   = 1
                
                XCTKAssertNotEqual(expr1, expr2, accuracy: 0, message())
            }
            
        case .identical:
            
            let object = TestError() as AnyObject
            
            XCTKAssertIdentical(object, object, message())
            
        case .notIdentical:
            
            let object1     = TestError() as AnyObject
            let object2     = TestError() as AnyObject
            
            XCTKAssertNotIdentical(object1, object2, message())
            
        case .greaterThan:
            
            XCTKAssertGreaterThan(1, 0, message())
            
        case .greaterThanOrEqual:
            
            XCTKAssertGreaterThanOrEqual(1, 0, message())
            
        case .lessThan:
            
            XCTKAssertLessThan(0, 1, message())
            
        case .lessThanOrEqual:
            
            XCTKAssertLessThanOrEqual(0, 1, message())
            
        case .nil:
            
            XCTKAssertNil(nil, message())
            
        case .notNil:
            
            XCTKAssertNotNil(Optional<Int>(1), message())
            
        case .unwrap:
            
            _ = try? XCTKUnwrap(Optional<Int>(1), message())
            
        case .true:
            
            XCTKAssertTrue(true, message())
            
        case .false:
            
            XCTKAssertFalse(false, message())
            
        case .fail:
            
            return
            
        case .throwsError:
            
            let expr: () throws -> Int = { try TestError.throwError() }
            
            XCTKAssertThrowsError(try expr(), message())
            
        case .noThrow:
            
            let expr: () throws -> Int = { return 0 }
            
            XCTKAssertNoThrow(try expr(), message())
    }
    
    XCTAssertEqual(count, 0)
}



/// Asserts that the message of the specified assertion is evaluated only
/// once when the assertion fails.
/// - Parameters:
///   - kind: The assertion to use.
///   - useFloats: Whether to use floating-point numbers when testing for
///   equality with accuracy. Otherwise, integers will be used.
internal func testFunctionAssertionMessageEvalOnceOnFailure(
    _ kind      : AssertionKind,
    useFloats   : Bool          = false
)
{
    var count   : Int           = 0
    let message : () -> String  = { count += 1; return "msg" }
    
    /// The compiler infers a throwing closure due to `try` in the `.noThrow`
    /// case, even though the assertion function catches the error internally.
    /// If `do`/`catch` is used, then the compiler correctly infers that no
    /// error is thrown, but emits a warning. Using `try?` at the assertion
    /// level interferes with the test. Use `try?` here to silence the issue.
    try? XCTExpectFailure()
    {
        switch kind
        {
            case .assert:
                
                XCTKAssert(false, message())
                
            case .equal:
                
                XCTKAssertEqual(0, 1, message())
                
            case .notEqual:
                
                XCTKAssertNotEqual(1, 1, message())
                
            case .equalWithAccuracy:
                
                if useFloats
                {
                    XCTKAssertEqual(0.0, 1.0, accuracy: 0.5, message())
                }
                else
                {
                    let expr1   : Int   = 0
                    let expr2   : Int   = 1
                    
                    XCTKAssertEqual(expr1, expr2, accuracy: 0, message())
                }
                
            case .notEqualWithAccuracy:
                
                if useFloats
                {
                    XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0, message())
                }
                else
                {
                    let expr1   : Int   = 0
                    let expr2   : Int   = 1
                    
                    XCTKAssertNotEqual(expr1, expr2, accuracy: 1, message())
                }
                
            case .identical:
                
                let object1     = TestError() as AnyObject
                let object2     = TestError() as AnyObject
                
                XCTKAssertIdentical(object1, object2, message())
                
            case .notIdentical:
                
                let object = TestError() as AnyObject
                
                XCTKAssertNotIdentical(object, object, message())
                
            case .greaterThan:
                
                XCTKAssertGreaterThan(0, 1, message())
                
            case .greaterThanOrEqual:
                
                XCTKAssertGreaterThanOrEqual(0, 1, message())
                
            case .lessThan:
                
                XCTKAssertLessThan(1, 0, message())
                
            case .lessThanOrEqual:
                
                XCTKAssertLessThanOrEqual(1, 0, message())
                
            case .nil:
                
                XCTKAssertNil(1, message())
                
            case .notNil:
                
                XCTKAssertNotNil(nil, message())
                
            case .unwrap:
                
                _ = try? XCTKUnwrap(Optional<Int>(nil), message())
                
            case .true:
                
                XCTKAssertTrue(false, message())
                
            case .false:
                
                XCTKAssertFalse(true, message())
                
            case .fail:
                
                XCTKFail(message())
                
            case .throwsError:
                
                let expr: () throws -> Int = { return 0 }
                
                XCTKAssertThrowsError(try expr(), message())
                
            case .noThrow:
                
                let expr: () throws -> Int = { try TestError.throwError() }
                
                XCTKAssertNoThrow(try expr(), message())
        }
    }
    
    XCTAssertEqual(count, 1)
}



// MARK: - Macros

/// Asserts that the message of the specified assertion is not evaluated
/// when the assertion succeeds.
///
/// - Note: This does nothing for ``AssertionKind/fail``.
///
/// - Parameters:
///   - kind: The assertion to use.
///   - useFloats: Whether to use floating-point numbers when testing for
///   equality with accuracy. Otherwise, integers will be used.
internal func testMacroAssertionMessageNotEvalOnSuccess(
    _ kind      : AssertionKind,
    useFloats   : Bool          = false
)
{
    var count   : Int           = 0
    let message : () -> String  = { count += 1; return "msg" }
    
    switch kind
    {
        case .assert:
            
            #XCTKAssert(true, message())
            
        case .equal:
            
            #XCTKAssertEqual(1, 1, message())
            
        case .notEqual:
            
            #XCTKAssertNotEqual(0, 1, message())
            
        case .equalWithAccuracy:
            
            if useFloats
            {
                #XCTKAssertEqual(1.0, 1.0, accuracy: 0.5, message())
            }
            else
            {
                let expr1   : Int   = 1
                let expr2   : Int   = 1
                
                #XCTKAssertEqual(expr1, expr2, accuracy: 1, message())
            }
            
        case .notEqualWithAccuracy:
            
            if useFloats
            {
                #XCTKAssertNotEqual(0.0, 1.0, accuracy: 0.0, message())
            }
            else
            {
                let expr1   : Int   = 0
                let expr2   : Int   = 1
                
                #XCTKAssertNotEqual(expr1, expr2, accuracy: 0, message())
            }
            
        case .identical:
            
            let object = TestError() as AnyObject
            
            #XCTKAssertIdentical(object, object, message())
            
        case .notIdentical:
            
            let object1     = TestError() as AnyObject
            let object2     = TestError() as AnyObject
            
            #XCTKAssertNotIdentical(object1, object2, message())
            
        case .greaterThan:
            
            #XCTKAssertGreaterThan(1, 0, message())
            
        case .greaterThanOrEqual:
            
            #XCTKAssertGreaterThanOrEqual(1, 0, message())
            
        case .lessThan:
            
            #XCTKAssertLessThan(0, 1, message())
            
        case .lessThanOrEqual:
            
            #XCTKAssertLessThanOrEqual(0, 1, message())
            
        case .nil:
            
            #XCTKAssertNil(nil, message())
            
        case .notNil:
            
            #XCTKAssertNotNil(Optional<Int>(1), message())
            
        case .unwrap:
            
            _ = try? #XCTKUnwrap(Optional<Int>(1), message())
            
        case .true:
            
            #XCTKAssertTrue(true, message())
            
        case .false:
            
            #XCTKAssertFalse(false, message())
            
        case .fail:
            
            return
            
        case .throwsError:
            
            let expr: () throws -> Int = { try TestError.throwError() }
            
            #XCTKAssertThrowsError(try expr(), message())
            
        case .noThrow:
            
            let expr: () throws -> Int = { return 0 }
            
            #XCTKAssertNoThrow(try expr(), message())
    }
    
    XCTAssertEqual(count, 0)
}



/// Asserts that the message of the specified assertion is evaluated only
/// once when the assertion fails.
/// - Parameters:
///   - kind: The assertion to use.
///   - useFloats: Whether to use floating-point numbers when testing for
///   equality with accuracy. Otherwise, integers will be used.
internal func testMacroAssertionMessageEvalOnceOnFailure(
    _ kind      : AssertionKind,
    useFloats   : Bool          = false
)
{
    var count   : Int           = 0
    let message : () -> String  = { count += 1; return "msg" }
    
    XCTExpectFailure()
    {
        switch kind
        {
            case .assert:
                
                #XCTKAssert(false, message())
                
            case .equal:
                
                #XCTKAssertEqual(0, 1, message())
                
            case .notEqual:
                
                #XCTKAssertNotEqual(1, 1, message())
                
            case .equalWithAccuracy:
                
                if useFloats
                {
                    #XCTKAssertEqual(0.0, 1.0, accuracy: 0.5, message())
                }
                else
                {
                    let expr1   : Int   = 0
                    let expr2   : Int   = 1
                    
                    #XCTKAssertEqual(expr1, expr2, accuracy: 0, message())
                }
                
            case .notEqualWithAccuracy:
                
                if useFloats
                {
                    #XCTKAssertNotEqual(0.0, 1.0, accuracy: 1.0, message())
                }
                else
                {
                    let expr1   : Int   = 0
                    let expr2   : Int   = 1
                    
                    #XCTKAssertNotEqual(expr1, expr2, accuracy: 1, message())
                }
                
            case .identical:
                
                let object1     = TestError() as AnyObject
                let object2     = TestError() as AnyObject
                
                #XCTKAssertIdentical(object1, object2, message())
                
            case .notIdentical:
                
                let object = TestError() as AnyObject
                
                #XCTKAssertNotIdentical(object, object, message())
                
            case .greaterThan:
                
                #XCTKAssertGreaterThan(0, 1, message())
                
            case .greaterThanOrEqual:
                
                #XCTKAssertGreaterThanOrEqual(0, 1, message())
                
            case .lessThan:
                
                #XCTKAssertLessThan(1, 0, message())
                
            case .lessThanOrEqual:
                
                #XCTKAssertLessThanOrEqual(1, 0, message())
                
            case .nil:
                
                #XCTKAssertNil(1, message())
                
            case .notNil:
                
                #XCTKAssertNotNil(nil, message())
                
            case .unwrap:
                
                _ = try? #XCTKUnwrap(Optional<Int>(nil), message())
                
            case .true:
                
                #XCTKAssertTrue(false, message())
                
            case .false:
                
                #XCTKAssertFalse(true, message())
                
            case .fail:
                
                #XCTKFail(message())
                
            case .throwsError:
                
                let expr: () throws -> Int = { return 0 }
                
                #XCTKAssertThrowsError(try expr(), message())
                
            case .noThrow:
                
                let expr: () throws -> Int = { try TestError.throwError() }
                
                #XCTKAssertNoThrow(try expr(), message())
        }
    }
    
    XCTAssertEqual(count, 1)
}
