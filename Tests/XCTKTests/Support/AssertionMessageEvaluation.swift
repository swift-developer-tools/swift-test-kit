//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TKTestSupport
import XCTest
@testable import XCTestKit



extension XCTestKitCase
{
    // MARK: - Functions

    /// Asserts that the message of the specified assertion is not evaluated
    /// when the assertion succeeds.
    ///
    /// - Note: This immediately fails ``AssertionKind/fail``.
    ///
    /// - Note: This also tests the options path for all assertions.
    ///
    /// - Parameters:
    ///   - kind: The assertion to test.
    ///   - useFloats: Whether to use floating-point numbers when testing for
    ///   equality with accuracy. Otherwise, integers will be used.
    internal func testFunctionAssertionMessageNotEvalOnSuccess(
        _ kind      : AssertionKind,
        useFloats   : Bool          = false
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        let options : TKOptions      = .init()
        
        switch kind
        {
            case .assert:
                
                XCTKAssert(
                    true,
                    message(),
                    options: options
                )
                
            case .equal:
                
                XCTKAssertEqual(
                    1,
                    1,
                    message(),
                    options: options
                )
                
            case .notEqual:
                
                XCTKAssertNotEqual(
                    0,
                    1,
                    message(),
                    options: options
                )
                
            case .equalWithAccuracy:
                
                if useFloats
                {
                    XCTKAssertEqual(
                        1.0,
                        1.0,
                        accuracy: 0.5,
                        message(),
                        options: options
                    )
                }
                else
                {
                    let expr1   : Int   = 1
                    let expr2   : Int   = 1
                    
                    XCTKAssertEqual(
                        expr1,
                        expr2,
                        accuracy: 1,
                        message(),
                        options: options
                    )
                }
                
            case .notEqualWithAccuracy:
                
                if useFloats
                {
                    XCTKAssertNotEqual(
                        0.0,
                        1.0,
                        accuracy: 0.0,
                        message(),
                        options: options
                    )
                }
                else
                {
                    let expr1   : Int   = 0
                    let expr2   : Int   = 1
                    
                    XCTKAssertNotEqual(
                        expr1,
                        expr2,
                        accuracy: 0,
                        message(),
                        options: options
                    )
                }
                
            case .identical:
                
                let object = TestError() as AnyObject
                
                XCTKAssertIdentical(
                    object,
                    object,
                    message(),
                    options: options
                )
                
            case .notIdentical:
                
                let object1     = TestError() as AnyObject
                let object2     = TestError() as AnyObject
                
                XCTKAssertNotIdentical(
                    object1,
                    object2,
                    message(),
                    options: options
                )
                
            case .greaterThan:
                
                XCTKAssertGreaterThan(
                    1,
                    0,
                    message(),
                    options: options
                )
                
            case .greaterThanOrEqual:
                
                XCTKAssertGreaterThanOrEqual(
                    1,
                    0,
                    message(),
                    options: options
                )
                
            case .lessThan:
                
                XCTKAssertLessThan(
                    0,
                    1,
                    message(),
                    options: options
                )
                
            case .lessThanOrEqual:
                
                XCTKAssertLessThanOrEqual(
                    0,
                    1,
                    message(),
                    options: options
                )
                
            case .nil:
                
                XCTKAssertNil(
                    nil,
                    message(),
                    options: options
                )
                
            case .notNil:
                
                XCTKAssertNotNil(
                    Optional<Int>(1),
                    message(),
                    options: options
                )
                
            case .unwrap:
                
                _ = try? XCTKUnwrap(
                    Optional<Int>(1),
                    message(),
                    options: options
                )
                
            case .true:
                
                XCTKAssertTrue(
                    true,
                    message(),
                    options: options
                )
                
            case .false:
                
                XCTKAssertFalse(
                    false,
                    message(),
                    options: options
                )
                
            case .throwsError:
                
                let expr: () throws -> Int = { throw TestError() }
                
                XCTKAssertThrowsError(
                    try expr(),
                    message(),
                    options: options
                )
                
            case .noThrow:
                
                let expr: () throws -> Int = { return 0 }
                
                XCTKAssertNoThrow(
                    try expr(),
                    message(),
                    options: options
                )
                
            case .satisfyAll:
                
                XCTKAssertAllSatisfy(
                    ["a", "b", "c"],
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyAny:
                
                XCTKAssertAnySatisfy(
                    ["a", "b", "c"],
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyNone:
                
                XCTKAssertNoneSatisfy(
                    ["a", "b", "c"],
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyAtLeast:
                
                XCTKAssertSatisfy(
                    ["a", "b", "c"],
                    atLeast: 1,
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyAtMost:
                
                XCTKAssertSatisfy(
                    ["a", "b", ""],
                    atMost: 1,
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyRange:
                
                XCTKAssertSatisfy(
                    ["a", "b", "c"],
                    range: 1...3,
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .exactly:
                
                XCTKAssertExactly(
                    ["a", "b", ""],
                    count: 1,
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .exactlyOne:
                
                XCTKAssertExactlyOne(
                    ["a", "b", ""],
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .sorted:
                
                XCTKAssertSorted(
                    ["a", "b", "c"],
                    by: { $0 < $1 },
                    message(),
                    options: options
                )
                
            case .unique:
                
                XCTKAssertUnique(
                    ["a", "b", "c"],
                    message(),
                    options: options
                )
                
            case .uniqueByKey:
                
                XCTKAssertUnique(
                    ["a", "b", "c"],
                    by: { $0.first },
                    message(),
                    options: options
                )
                
            case .fail:
                
                XCTFail("Invalid assertion: \(kind.name)")
                return
        }
        
        XCTAssertEqual(count, 0)
    }



    /// Asserts that the message of the specified assertion is evaluated only
    /// once when the assertion fails.
    /// - Parameters:
    ///   - kind: The assertion to test.
    ///   - useFloats: Whether to use floating-point numbers when testing for
    ///   equality with accuracy. Otherwise, integers will be used.
    internal func testFunctionAssertionMessageEvalOnceOnFailure(
        _ kind      : AssertionKind,
        useFloats   : Bool          = false
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        withOneExpectedFailure
        {
            switch kind
            {
                case .assert:
                    
                    XCTKAssert(
                        false,
                        message()
                    )
                    
                case .equal:
                    
                    XCTKAssertEqual(
                        0,
                        1,
                        message()
                    )
                    
                case .notEqual:
                    
                    XCTKAssertNotEqual(
                        1,
                        1,
                        message()
                    )
                    
                case .equalWithAccuracy:
                    
                    if useFloats
                    {
                        XCTKAssertEqual(
                            0.0,
                            1.0,
                            accuracy: 0.5,
                            message()
                        )
                    }
                    else
                    {
                        let expr1   : Int   = 0
                        let expr2   : Int   = 1
                        
                        XCTKAssertEqual(
                            expr1,
                            expr2,
                            accuracy: 0,
                            message()
                        )
                    }
                    
                case .notEqualWithAccuracy:
                    
                    if useFloats
                    {
                        XCTKAssertNotEqual(
                            0.0,
                            1.0,
                            accuracy: 1.0,
                            message()
                        )
                    }
                    else
                    {
                        let expr1   : Int   = 0
                        let expr2   : Int   = 1
                        
                        XCTKAssertNotEqual(
                            expr1,
                            expr2,
                            accuracy: 1,
                            message()
                        )
                    }
                    
                case .identical:
                    
                    let object1     = TestError() as AnyObject
                    let object2     = TestError() as AnyObject
                    
                    XCTKAssertIdentical(
                        object1,
                        object2,
                        message()
                    )
                    
                case .notIdentical:
                    
                    let object = TestError() as AnyObject
                    
                    XCTKAssertNotIdentical(
                        object,
                        object,
                        message()
                    )
                    
                case .greaterThan:
                    
                    XCTKAssertGreaterThan(
                        0,
                        1,
                        message()
                    )
                    
                case .greaterThanOrEqual:
                    
                    XCTKAssertGreaterThanOrEqual(
                        0,
                        1,
                        message()
                    )
                    
                case .lessThan:
                    
                    XCTKAssertLessThan(
                        1,
                        0,
                        message()
                    )
                    
                case .lessThanOrEqual:
                    
                    XCTKAssertLessThanOrEqual(
                        1,
                        0,
                        message()
                    )
                    
                case .nil:
                    
                    XCTKAssertNil(
                        1,
                        message()
                    )
                    
                case .notNil:
                    
                    XCTKAssertNotNil(
                        nil,
                        message()
                    )
                    
                case .unwrap:
                    
                    _ = try XCTKUnwrap(
                        Optional<Int>(nil),
                        message()
                    )
                    
                case .true:
                    
                    XCTKAssertTrue(
                        false,
                        message()
                    )
                    
                case .false:
                    
                    XCTKAssertFalse(
                        true,
                        message()
                    )
                    
                case .fail:
                    
                    XCTKFail(message())
                    
                case .throwsError:
                    
                    let expr: () throws -> Int = { return 0 }
                    
                    XCTKAssertThrowsError(
                        try expr(),
                        message()
                    )
                    
                case .noThrow:
                    
                    let expr: () throws -> Int = { throw TestError() }
                    
                    XCTKAssertNoThrow(
                        try expr(),
                        message()
                    )
                    
                case .satisfyAll:
                    
                    XCTKAssertAllSatisfy(
                        ["a", "b", "c"],
                        { $0.isEmpty },
                        message()
                    )
                    
                case .satisfyAny:
                    
                    XCTKAssertAnySatisfy(
                        ["a", "b", "c"],
                        { $0.isEmpty },
                        message()
                    )
                    
                case .satisfyNone:
                    
                    XCTKAssertNoneSatisfy(
                        ["a", "b", "c"],
                        { !$0.isEmpty },
                        message()
                    )
                    
                case .satisfyAtLeast:
                    
                    XCTKAssertSatisfy(
                        ["a", "b", "c"],
                        atLeast: 1,
                        { $0.isEmpty },
                        message()
                    )
                    
                case .satisfyAtMost:
                    
                    XCTKAssertSatisfy(
                        ["a", "b", "c"],
                        atMost: 1,
                        { !$0.isEmpty },
                        message()
                    )
                    
                case .satisfyRange:
                    
                    XCTKAssertSatisfy(
                        ["a", "b", "c"],
                        range: 1...3,
                        { $0.isEmpty },
                        message()
                    )
                    
                case .exactly:
                    
                    XCTKAssertExactly(
                        ["a", "b", "c"],
                        count: 1,
                        { $0.isEmpty },
                        message()
                    )
                    
                case .exactlyOne:
                    
                    XCTKAssertExactlyOne(
                        ["a", "b", "c"],
                        { $0.isEmpty },
                        message()
                    )
                    
                case .sorted:
                    
                    XCTKAssertSorted(
                        ["a", "b", "c"],
                        by: { $0 > $1 },
                        message()
                    )
                    
                case .unique:
                    
                    XCTKAssertUnique(
                        ["a", "a", "a"],
                        message()
                    )
                    
                case .uniqueByKey:
                    
                    XCTKAssertUnique(
                        ["a", "a", "a"],
                        by: { $0.first },
                        message()
                    )
            }
        }
        
        XCTAssertEqual(count, 1)
    }



    // MARK: - Macros

    /// Asserts that the message of the specified assertion is not evaluated
    /// when the assertion succeeds.
    ///
    /// - Note: This immediately fails ``AssertionKind/fail``.
    ///
    /// - Note: This also tests the options path for all assertions.
    ///
    /// - Parameters:
    ///   - kind: The assertion to test.
    ///   - useFloats: Whether to use floating-point numbers when testing for
    ///   equality with accuracy. Otherwise, integers will be used.
    internal func testMacroAssertionMessageNotEvalOnSuccess(
        _ kind      : AssertionKind,
        useFloats   : Bool          = false
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        let options : TKOptions     = .init()
        
        switch kind
        {
            case .assert:
                
                #XCTKAssert(
                    true,
                    message(),
                    options: options
                )
                
            case .equal:
                
                #XCTKAssertEqual(
                    1,
                    1,
                    message(),
                    options: options
                )
                
            case .notEqual:
                
                #XCTKAssertNotEqual(
                    0,
                    1,
                    message(),
                    options: options
                )
                
            case .equalWithAccuracy:
                
                if useFloats
                {
                    #XCTKAssertEqual(
                        1.0,
                        1.0,
                        accuracy: 0.5,
                        message(),
                        options: options
                    )
                }
                else
                {
                    let expr1   : Int   = 1
                    let expr2   : Int   = 1
                    
                    #XCTKAssertEqual(
                        expr1,
                        expr2,
                        accuracy: 1,
                        message(),
                        options: options
                    )
                }
                
            case .notEqualWithAccuracy:
                
                if useFloats
                {
                    #XCTKAssertNotEqual(
                        0.0,
                        1.0,
                        accuracy: 0.0,
                        message(),
                        options: options
                    )
                }
                else
                {
                    let expr1   : Int   = 0
                    let expr2   : Int   = 1
                    
                    #XCTKAssertNotEqual(
                        expr1,
                        expr2,
                        accuracy: 0,
                        message(),
                        options: options
                    )
                }
                
            case .identical:
                
                let object = TestError() as AnyObject
                
                #XCTKAssertIdentical(
                    object,
                    object,
                    message(),
                    options: options
                )
                
            case .notIdentical:
                
                let object1     = TestError() as AnyObject
                let object2     = TestError() as AnyObject
                
                #XCTKAssertNotIdentical(
                    object1,
                    object2,
                    message(),
                    options: options
                )
                
            case .greaterThan:
                
                #XCTKAssertGreaterThan(
                    1,
                    0,
                    message(),
                    options: options
                )
                
            case .greaterThanOrEqual:
                
                #XCTKAssertGreaterThanOrEqual(
                    1,
                    0,
                    message(),
                    options: options
                )
                
            case .lessThan:
                
                #XCTKAssertLessThan(
                    0,
                    1,
                    message(),
                    options: options
                )
                
            case .lessThanOrEqual:
                
                #XCTKAssertLessThanOrEqual(
                    0,
                    1,
                    message(),
                    options: options
                )
                
            case .nil:
                
                #XCTKAssertNil(
                    nil,
                    message(),
                    options: options
                )
                
            case .notNil:
                
                #XCTKAssertNotNil(
                    Optional<Int>(1),
                    message(),
                    options: options
                )
                
            case .unwrap:
                
                _ = try? #XCTKUnwrap(
                    Optional<Int>(1),
                    message(),
                    options: options
                )
                
            case .true:
                
                #XCTKAssertTrue(
                    true,
                    message(),
                    options: options
                )
                
            case .false:
                
                #XCTKAssertFalse(
                    false,
                    message(),
                    options: options
                )
                
            case .throwsError:
                
                let expr: () throws -> Int = { throw TestError() }
                
                #XCTKAssertThrowsError(
                    try expr(),
                    message(),
                    options: options
                )
                
            case .noThrow:
                
                let expr: () throws -> Int = { return 0 }
                
                #XCTKAssertNoThrow(
                    try expr(),
                    message(),
                    options: options
                )
                
                
            case .satisfyAll:
                            
                #XCTKAssertAllSatisfy(
                    ["a", "b", "c"],
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyAny:
                
                #XCTKAssertAnySatisfy(
                    ["a", "b", "c"],
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyNone:
                
                #XCTKAssertNoneSatisfy(
                    ["a", "b", "c"],
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyAtLeast:
                
                #XCTKAssertSatisfy(
                    ["a", "b", "c"],
                    atLeast: 1,
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyAtMost:
                
                #XCTKAssertSatisfy(
                    ["a", "b", ""],
                    atMost: 1,
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .satisfyRange:
                
                #XCTKAssertSatisfy(
                    ["a", "b", "c"],
                    range: 1...3,
                    { !$0.isEmpty },
                    message(),
                    options: options
                )
                
            case .exactly:
                
                #XCTKAssertExactly(
                    ["a", "b", ""],
                    count: 1,
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .exactlyOne:
                
                #XCTKAssertExactlyOne(
                    ["a", "b", ""],
                    { $0.isEmpty },
                    message(),
                    options: options
                )
                
            case .sorted:
                
                #XCTKAssertSorted(
                    ["a", "b", "c"],
                    by: { $0 < $1 },
                    message(),
                    options: options
                )
                
            case .unique:
                
                #XCTKAssertUnique(
                    ["a", "b", "c"],
                    message(),
                    options: options
                )
                
            case .uniqueByKey:
                
                #XCTKAssertUnique(
                    ["a", "b", "c"],
                    by: { $0.first },
                    message(),
                    options: options
                )
                
            case .fail:
                
                XCTFail("Invalid assertion: \(kind.macroDisplayName)")
                return
        }
        
        XCTAssertEqual(count, 0)
    }



    /// Asserts that the message of the specified assertion is evaluated only
    /// once when the assertion fails.
    /// - Parameters:
    ///   - kind: The assertion to test.
    ///   - useFloats: Whether to use floating-point numbers when testing for
    ///   equality with accuracy. Otherwise, integers will be used.
    internal func testMacroAssertionMessageEvalOnceOnFailure(
        _ kind      : AssertionKind,
        useFloats   : Bool          = false
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        withOneExpectedFailure
        {
            switch kind
            {
                case .assert:
                    
                    #XCTKAssert(
                        false,
                        message()
                    )
                    
                case .equal:
                    
                    #XCTKAssertEqual(
                        0,
                        1,
                        message()
                    )
                    
                case .notEqual:
                    
                    #XCTKAssertNotEqual(
                        1,
                        1,
                        message()
                    )
                    
                case .equalWithAccuracy:
                    
                    if useFloats
                    {
                        #XCTKAssertEqual(
                            0.0,
                            1.0,
                            accuracy: 0.5,
                            message()
                        )
                    }
                    else
                    {
                        let expr1   : Int   = 0
                        let expr2   : Int   = 1
                        
                        #XCTKAssertEqual(
                            expr1,
                            expr2,
                            accuracy: 0,
                            message()
                        )
                    }
                    
                case .notEqualWithAccuracy:
                    
                    if useFloats
                    {
                        #XCTKAssertNotEqual(
                            0.0,
                            1.0,
                            accuracy: 1.0,
                            message()
                        )
                    }
                    else
                    {
                        let expr1   : Int   = 0
                        let expr2   : Int   = 1
                        
                        #XCTKAssertNotEqual(
                            expr1,
                            expr2,
                            accuracy: 1,
                            message()
                        )
                    }
                    
                case .identical:
                    
                    let object1     = TestError() as AnyObject
                    let object2     = TestError() as AnyObject
                    
                    #XCTKAssertIdentical(
                        object1,
                        object2,
                        message()
                    )
                    
                case .notIdentical:
                    
                    let object = TestError() as AnyObject
                    
                    #XCTKAssertNotIdentical(
                        object,
                        object,
                        message()
                    )
                    
                case .greaterThan:
                    
                    #XCTKAssertGreaterThan(
                        0,
                        1,
                        message()
                    )
                    
                case .greaterThanOrEqual:
                    
                    #XCTKAssertGreaterThanOrEqual(
                        0,
                        1,
                        message()
                    )
                    
                case .lessThan:
                    
                    #XCTKAssertLessThan(
                        1,
                        0,
                        message()
                    )
                    
                case .lessThanOrEqual:
                    
                    #XCTKAssertLessThanOrEqual(
                        1,
                        0,
                        message()
                    )
                    
                case .nil:
                    
                    #XCTKAssertNil(
                        1,
                        message()
                    )
                    
                case .notNil:
                    
                    #XCTKAssertNotNil(
                        nil,
                        message()
                    )
                    
                case .unwrap:
                    
                    _ = try #XCTKUnwrap(
                        Optional<Int>(nil),
                        message()
                    )
                    
                case .true:
                    
                    #XCTKAssertTrue(
                        false,
                        message()
                    )
                    
                case .false:
                    
                    #XCTKAssertFalse(
                        true,
                        message()
                    )
                    
                case .fail:
                    
                    #XCTKFail(message())
                    
                case .throwsError:
                    
                    let expr: () throws -> Int = { return 0 }
                    
                    #XCTKAssertThrowsError(
                        try expr(),
                        message()
                    )
                    
                case .noThrow:
                    
                    let expr: () throws -> Int = { throw TestError() }
                    
                    #XCTKAssertNoThrow(
                        try expr(),
                        message()
                    )
                    
                case .satisfyAll:
                                    
                    #XCTKAssertAllSatisfy(
                        ["a", "b", "c"],
                        { $0.isEmpty },
                        message()
                    )
                    
                case .satisfyAny:
                    
                    #XCTKAssertAnySatisfy(
                        ["a", "b", "c"],
                        { $0.isEmpty },
                        message()
                    )
                    
                case .satisfyNone:
                    
                    #XCTKAssertNoneSatisfy(
                        ["a", "b", "c"],
                        { !$0.isEmpty },
                        message()
                    )
                    
                case .satisfyAtLeast:
                    
                    #XCTKAssertSatisfy(
                        ["a", "b", "c"],
                        atLeast: 1,
                        { $0.isEmpty },
                        message()
                    )
                    
                case .satisfyAtMost:
                    
                    #XCTKAssertSatisfy(
                        ["a", "b", "c"],
                        atMost: 1,
                        { !$0.isEmpty },
                        message()
                    )
                    
                case .satisfyRange:
                    
                    #XCTKAssertSatisfy(
                        ["a", "b", "c"],
                        range: 1...3,
                        { $0.isEmpty },
                        message()
                    )
                    
                case .exactly:
                    
                    #XCTKAssertExactly(
                        ["a", "b", "c"],
                        count: 1,
                        { $0.isEmpty },
                        message()
                    )
                    
                case .exactlyOne:
                    
                    #XCTKAssertExactlyOne(
                        ["a", "b", "c"],
                        { $0.isEmpty },
                        message()
                    )
                    
                case .sorted:
                    
                    #XCTKAssertSorted(
                        ["a", "b", "c"],
                        by: { $0 > $1 },
                        message()
                    )
                    
                case .unique:
                    
                    #XCTKAssertUnique(
                        ["a", "a", "a"],
                        message()
                    )
                    
                case .uniqueByKey:
                    
                    #XCTKAssertUnique(
                        ["a", "a", "a"],
                        by: { $0.first },
                        message()
                    )
            }
        }
        
        XCTAssertEqual(count, 1)
    }
}
