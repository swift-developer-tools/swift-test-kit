//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class FunctionAssertionMessageTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.fail)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAllMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyAnyMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyNoneMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyAtMostMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.satisfyRange)
    }
    
    
    
    func testAssertSatisfyRangeMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.satisfyRange)
    }
    
    
    
    func testAssertExactlyMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.exactly)
    }
    
    
    
    func testAssertExactlyMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.exactly)
    }
    
    
    
    func testAssertExactlyOneMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.exactlyOne)
    }
    
    
    
    func testAssertExactlyOneMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.exactlyOne)
    }
    
    
    
    func testAssertSortedMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.sorted)
    }
    
    
    
    func testAssertSortedMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.sorted)
    }
    
    
    
    func testAssertUniqueMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.unique)
    }
    
    
    
    func testAssertUniqueMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.unique)
    }
    
    
    
    func testAssertUniqueByKeyMessageNotEvalOnSuccess() throws
    {
        testFunctionAssertionMessageNotEvalOnSuccess(.uniqueByKey)
    }
    
    
    
    func testAssertUniqueByKeyMessageEvalOnlyOnceOnFailure() throws
    {
        testFunctionAssertionMessageEvalOnceOnFailure(.uniqueByKey)
    }
}
