//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class MacroAssertionMessageTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.fail)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAllMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyAnyMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyNoneMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyAtMostMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyRange)
    }
    
    
    
    func testAssertSatisfyRangeMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyRange)
    }
    
    
    
    func testAssertExactlyMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.exactly)
    }
    
    
    
    func testAssertExactlyMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.exactly)
    }
    
    
    
    func testAssertExactlyOneMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.exactlyOne)
    }
    
    
    
    func testAssertExactlyOneMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.exactlyOne)
    }
    
    
    
    func testAssertSortedMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.sorted)
    }
    
    
    
    func testAssertSortedMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.sorted)
    }
    
    
    
    func testAssertUniqueMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.unique)
    }
    
    
    
    func testAssertUniqueMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.unique)
    }
    
    
    
    func testAssertUniqueByKeyMessageNotEvalOnSuccess()
    {
        testMacroAssertionMessageNotEvalOnSuccess(.uniqueByKey)
    }
    
    
    
    func testAssertUniqueByKeyMessageEvalOnlyOnceOnFailure()
    {
        testMacroAssertionMessageEvalOnceOnFailure(.uniqueByKey)
    }
}
