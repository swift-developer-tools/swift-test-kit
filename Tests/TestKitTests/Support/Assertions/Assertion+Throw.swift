//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



extension TestKitCase
{
    // MARK: - Functions

    /// Asserts that specified assertion fails when an error is thrown.
    ///
    /// - Note: This immediately fails ``AssertionKind/fail`` and
    /// ``AssertionKind/throwsError``.
    ///
    /// - Parameter kind: The assertion to test.
    internal func assertFuncAssertionFailsOnThrow(
        _ kind: AssertionKind
    )
    {
        let expr        : () throws -> Int          = { throw TestError() }
        let collection  : () throws -> [String]     = { throw TestError() }
        
        let message: String? = withOneExpectedFailure
        {
            switch kind
            {
                case .assert:
                    
                    TKAssert(try expr() == 1)
                    
                case .equal:
                    
                    TKAssertEqual(
                        try expr(),
                        1
                    )
                    
                case .notEqual:
                    
                    TKAssertNotEqual(
                        try expr(),
                        1
                    )
                    
                case .equalWithAccuracy:
                    
                    TKAssertEqual(
                        try expr(),
                        1,
                        accuracy: 1
                    )
                    
                case .notEqualWithAccuracy:
                    
                    TKAssertNotEqual(
                        try expr(),
                        1,
                        accuracy: 1
                    )
                    
                case .identical:
                    
                    TKAssertIdentical(
                        try { throw TestError() }(),
                        TestError() as AnyObject
                    )
                    
                case .notIdentical:
                    
                    TKAssertNotIdentical(
                        try { throw TestError() }(),
                        TestError() as AnyObject
                    )
                    
                case .greaterThan:
                    
                    TKAssertGreaterThan(
                        try expr(),
                        1
                    )
                    
                case .greaterThanOrEqual:
                    
                    TKAssertGreaterThanOrEqual(
                        try expr(),
                        1
                    )
                    
                case .lessThan:
                    
                    TKAssertLessThan(
                        try expr(),
                        1
                    )
                    
                case .lessThanOrEqual:
                    
                    TKAssertLessThanOrEqual(
                        try expr(),
                        1
                    )
                    
                case .nil:
                    
                    TKAssertNil(try expr())
                    
                case .notNil:
                    
                    TKAssertNotNil(try expr())
                    
                case .unwrap:
                    
                    _ = try TKUnwrap(try expr())
                    
                case .true:
                    
                    TKAssertTrue(try expr() == 1)
                    
                case .false:
                    
                    TKAssertFalse(try expr() == 1)
                                        
                case .noThrow:
                    
                    TKAssertNoThrow(try expr())
                    
                case .satisfyAll:
                    
                    TKAssertAllSatisfy(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .satisfyAny:
                    
                    TKAssertAnySatisfy(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .satisfyNone:
                    
                    TKAssertNoneSatisfy(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .satisfyAtLeast:
                    
                    TKAssertSatisfy(
                        try collection(),
                        atLeast: 1,
                        { $0.isEmpty }
                    )
                    
                case .satisfyAtMost:
                    
                    TKAssertSatisfy(
                        try collection(),
                        atMost: 1,
                        { $0.isEmpty }
                    )
                    
                case .satisfyRange:
                    
                    TKAssertSatisfy(
                        try collection(),
                        range: 1...3,
                        { $0.isEmpty }
                    )
                    
                case .exactly:
                    
                    TKAssertExactly(
                        try collection(),
                        count: 1,
                        { $0.isEmpty }
                    )
                    
                case .exactlyOne:
                    
                    TKAssertExactlyOne(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .sorted:
                    
                    TKAssertSorted(
                        try collection(),
                        by: { $0 < $1 }
                    )
                    
                case .unique:
                    
                    TKAssertUnique(try collection())
                    
                case .uniqueByKey:
                    
                    TKAssertUnique(
                        try collection(),
                        by: { $0.first }
                    )
                    
                case
                    .fail,
                    .throwsError:
                    
                    XCTFail("Invalid assertion: \(kind.name)")
                    return
            }
        }
        
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("threw error"))
        XCTAssertTrue(message!.contains("TestError"))
    }



    // MARK: - Macros

    /// Asserts that specified assertion fails when an error is thrown.
    ///
    /// - Note: This immediately fails ``AssertionKind/fail`` and
    /// ``AssertionKind/throwsError``.
    ///
    /// - Parameter kind: The assertion to test.
    internal func assertMacroAssertionFailsOnThrow(
        _ kind: AssertionKind
    )
    {
        let expr        : () throws -> Int          = { throw TestError() }
        let collection  : () throws -> [String]     = { throw TestError() }
        
        let message: String? = withOneExpectedFailure
        {
            switch kind
            {
                case .assert:
                    
                    #XCTKAssert(try expr() == 1)
                    
                case .equal:
                    
                    #XCTKAssertEqual(
                        try expr(),
                        1
                    )
                    
                case .notEqual:
                    
                    #XCTKAssertNotEqual(
                        try expr(),
                        1
                    )
                    
                case .equalWithAccuracy:
                    
                    #XCTKAssertEqual(
                        try expr(),
                        1,
                        accuracy: 1
                    )
                    
                case .notEqualWithAccuracy:
                    
                    #XCTKAssertNotEqual(
                        try expr(),
                        1,
                        accuracy: 1
                    )
                    
                case .identical:
                    
                    #XCTKAssertIdentical(
                        try { throw TestError() }(),
                        TestError() as AnyObject
                    )
                    
                case .notIdentical:
                    
                    #XCTKAssertNotIdentical(
                        try { throw TestError() }(),
                        TestError() as AnyObject
                    )
                    
                case .greaterThan:
                    
                    #XCTKAssertGreaterThan(
                        try expr(),
                        1
                    )
                    
                case .greaterThanOrEqual:
                    
                    #XCTKAssertGreaterThanOrEqual(
                        try expr(),
                        1
                    )
                    
                case .lessThan:
                    
                    #XCTKAssertLessThan(
                        try expr(),
                        1
                    )
                    
                case .lessThanOrEqual:
                    
                    #XCTKAssertLessThanOrEqual(
                        try expr(),
                        1
                    )
                    
                case .nil:
                    
                    #XCTKAssertNil(try expr())
                    
                case .notNil:
                    
                    #XCTKAssertNotNil(try expr())
                    
                case .unwrap:
                    
                    _ = try #XCTKUnwrap(try expr())
                    
                case .true:
                    
                    #XCTKAssertTrue(try expr() == 1)
                    
                case .false:
                    
                    #XCTKAssertFalse(try expr() == 1)
                    
                case .noThrow:
                    
                    #XCTKAssertNoThrow(try expr())
                 
                case .satisfyAll:
                                
                    #XCTKAssertAllSatisfy(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .satisfyAny:
                    
                    #XCTKAssertAnySatisfy(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .satisfyNone:
                    
                    #XCTKAssertNoneSatisfy(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .satisfyAtLeast:
                    
                    #XCTKAssertSatisfy(
                        try collection(),
                        atLeast: 1,
                        { $0.isEmpty }
                    )
                    
                case .satisfyAtMost:
                    
                    #XCTKAssertSatisfy(
                        try collection(),
                        atMost: 1,
                        { $0.isEmpty }
                    )
                    
                case .satisfyRange:
                    
                    #XCTKAssertSatisfy(
                        try collection(),
                        range: 1...3,
                        { $0.isEmpty }
                    )
                    
                case .exactly:
                    
                    #XCTKAssertExactly(
                        try collection(),
                        count: 1,
                        { $0.isEmpty }
                    )
                    
                case .exactlyOne:
                    
                    #XCTKAssertExactlyOne(
                        try collection(),
                        { $0.isEmpty }
                    )
                    
                case .sorted:
                    
                    #XCTKAssertSorted(
                        try collection(),
                        by: { $0 < $1 }
                    )
                    
                case .unique:
                    
                    #XCTKAssertUnique(try collection())
                    
                case .uniqueByKey:
                    
                    #XCTKAssertUnique(
                        try collection(),
                        by: { $0.first }
                    )
                    
                case
                    .fail,
                    .throwsError:
                    
                    XCTFail("Invalid assertion: \(kind.macroDisplayName)")
                    return
            }
        }
        
        let threwMessage: String = kind == .noThrow
            ? "Threw:"
            : "threw error"
        
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains(threwMessage))
        XCTAssertTrue(message!.contains("TestError"))
    }
}
