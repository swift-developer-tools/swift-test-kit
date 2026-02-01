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



extension XCTestKitCase
{
    // MARK: - Functions

    /// Asserts that specified assertion fails when an error is thrown.
    ///
    /// - Note: This immediately fails ``AssertionKind/fail`` and
    /// ``AssertionKind/throwsError``.
    ///
    /// - Parameter kind: The assertion to test.
    internal func testFunctionAssertionFailsOnThrow(
        _ kind: AssertionKind
    )
    {
        let expr: () throws -> Int = { try TestError.throwError() }
        
        let message: String? = withOneExpectedFailure
        {
            switch kind
            {
                case .assert:
                    
                    XCTKAssert(try expr() == 1)
                    
                case .equal:
                    
                    XCTKAssertEqual(
                        try expr(),
                        1
                    )
                    
                case .notEqual:
                    
                    XCTKAssertNotEqual(
                        try expr(),
                        1
                    )
                    
                case .equalWithAccuracy:
                    
                    XCTKAssertEqual(
                        try expr(),
                        1,
                        accuracy: 1
                    )
                    
                case .notEqualWithAccuracy:
                    
                    XCTKAssertNotEqual(
                        try expr(),
                        1,
                        accuracy: 1
                    )
                    
                case .identical:
                    
                    XCTKAssertIdentical(
                        try { throw TestError() }(),
                        TestError() as AnyObject
                    )
                    
                case .notIdentical:
                    
                    XCTKAssertNotIdentical(
                        try { throw TestError() }(),
                        TestError() as AnyObject
                    )
                    
                case .greaterThan:
                    
                    XCTKAssertGreaterThan(
                        try expr(),
                        1
                    )
                    
                case .greaterThanOrEqual:
                    
                    XCTKAssertGreaterThanOrEqual(
                        try expr(),
                        1
                    )
                    
                case .lessThan:
                    
                    XCTKAssertLessThan(
                        try expr(),
                        1
                    )
                    
                case .lessThanOrEqual:
                    
                    XCTKAssertLessThanOrEqual(
                        try expr(),
                        1
                    )
                    
                case .nil:
                    
                    XCTKAssertNil(try expr())
                    
                case .notNil:
                    
                    XCTKAssertNotNil(try expr())
                    
                case .unwrap:
                    
                    _ = try XCTKUnwrap(try expr())
                    
                case .true:
                    
                    XCTKAssertTrue(try expr() == 1)
                    
                case .false:
                    
                    XCTKAssertFalse(try expr() == 1)
                                        
                case .noThrow:
                    
                    XCTKAssertNoThrow(try expr())
                    
                case
                    .fail,
                    .throwsError:
                    
                    XCTFail("Invalid assertion: \(kind.name)")
                    return
                    
                default:
                    
                    // TODO: Add predicate cases
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
    internal func testMacroAssertionFailsOnThrow(
        _ kind: AssertionKind
    )
    {
        let expr: () throws -> Int = { try TestError.throwError() }
        
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
                    
                case
                    .fail,
                    .throwsError:
                    
                    XCTFail("Invalid assertion: \(kind.macroDisplayName)")
                    return
                    
                default:
                    
                    // TODO: Add predicate cases
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
