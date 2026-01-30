//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKitTestUtilities



internal final class MacroAssertionMessageTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvaluatedOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.fail)
    }
}
