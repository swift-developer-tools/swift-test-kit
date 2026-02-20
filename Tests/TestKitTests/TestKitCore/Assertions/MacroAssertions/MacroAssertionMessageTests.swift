//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class MacroAssertionMessageTests: TestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.fail)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAllMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyAnyMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyNoneMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyAtMostMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.satisfyRange)
    }
    
    
    
    func testAssertSatisfyRangeMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.satisfyRange)
    }
    
    
    
    func testAssertExactlyMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.exactly)
    }
    
    
    
    func testAssertExactlyMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.exactly)
    }
    
    
    
    func testAssertExactlyOneMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.exactlyOne)
    }
    
    
    
    func testAssertExactlyOneMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.exactlyOne)
    }
    
    
    
    func testAssertSortedMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.sorted)
    }
    
    
    
    func testAssertSortedMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.sorted)
    }
    
    
    
    func testAssertUniqueMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.unique)
    }
    
    
    
    func testAssertUniqueMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.unique)
    }
    
    
    
    func testAssertUniqueByKeyMessageNotEvalOnSuccess()
    {
        assertMacroAssertionMessageNotEvalOnSuccess(.uniqueByKey)
    }
    
    
    
    func testAssertUniqueByKeyMessageEvalOnlyOnceOnFailure()
    {
        assertMacroAssertionMessageEvalOnceOnFailure(.uniqueByKey)
    }
}
