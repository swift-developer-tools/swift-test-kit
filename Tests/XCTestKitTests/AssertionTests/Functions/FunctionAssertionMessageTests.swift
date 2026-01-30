//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKitTestUtilities



internal final class FunctionAssertionMessageTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvaluatedOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.fail)
    }
}
