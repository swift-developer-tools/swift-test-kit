//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class FunctionAssertionMessageTests: TestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.fail)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAllMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyAnyMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyNoneMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyAtMostMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.satisfyRange)
    }
    
    
    
    func testAssertSatisfyRangeMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.satisfyRange)
    }
    
    
    
    func testAssertExactlyMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.exactly)
    }
    
    
    
    func testAssertExactlyMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.exactly)
    }
    
    
    
    func testAssertExactlyOneMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.exactlyOne)
    }
    
    
    
    func testAssertExactlyOneMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.exactlyOne)
    }
    
    
    
    func testAssertSortedMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.sorted)
    }
    
    
    
    func testAssertSortedMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.sorted)
    }
    
    
    
    func testAssertUniqueMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.unique)
    }
    
    
    
    func testAssertUniqueMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.unique)
    }
    
    
    
    func testAssertUniqueByKeyMessageNotEvalOnSuccess()
    {
        assertFuncAssertionMessageNotEvalOnSuccess(.uniqueByKey)
    }
    
    
    
    func testAssertUniqueByKeyMessageEvalOnlyOnceOnFailure()
    {
        assertFuncAssertionMessageEvalOnceOnFailure(.uniqueByKey)
    }
}
