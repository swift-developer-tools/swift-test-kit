//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class MacroAssertionMessageTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.assert)
    }
    
    
    
    func testAssertTrueMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.true)
    }
    
    
    
    func testAssertTrueMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.true)
    }
    
    
    
    func testAssertFalseMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.false)
    }
    
    
    
    func testAssertFalseMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.nil)
    }
    
    
    
    func testAssertNilMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.nil)
    }
    
    
    
    func testAssertNotNilMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notNil)
    }
    
    
    
    func testUnwrapMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.equal)
    }
    
    
    
    func testAssertEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.equal)
    }
    
    
    
    func testAssertNotEqualMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notEqual)
    }
    
    
    
    func testAssertNotEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notEqual)
    }
    
    
    
    func testAssertIdenticalMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.identical)
    }
    
    
    
    func testAssertIdenticalMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.identical)
    }
    
    
    
    func testAssertNotIdenticalMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.notIdentical)
    }
    
    
    
    func testAssertNotIdenticalMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualFloatAccMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertEqualIntAccMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertEqualIntAccMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .equalWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualFloatAccMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: true
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    func testAssertNotEqualIntAccMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(
            .notEqualWithAccuracy,
            useFloats: false
        )
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.throwsError)
    }
    
    
    
    func testAssertNoThrowMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.noThrow)
    }
    
    
    
    // MARK: - Fail
    
    func testFailMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.fail)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAllMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyAnyMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyNoneMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtLeastMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyAtMostMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.satisfyRange)
    }
    
    
    
    func testAssertSatisfyRangeMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.satisfyRange)
    }
    
    
    
    func testAssertExactlyMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.exactly)
    }
    
    
    
    func testAssertExactlyMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.exactly)
    }
    
    
    
    func testAssertExactlyOneMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.exactlyOne)
    }
    
    
    
    func testAssertExactlyOneMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.exactlyOne)
    }
    
    
    
    func testAssertSortedMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.sorted)
    }
    
    
    
    func testAssertSortedMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.sorted)
    }
    
    
    
    func testAssertUniqueMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.unique)
    }
    
    
    
    func testAssertUniqueMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.unique)
    }
    
    
    
    func testAssertUniqueByKeyMessageNotEvalOnSuccess() throws
    {
        testMacroAssertionMessageNotEvalOnSuccess(.uniqueByKey)
    }
    
    
    
    func testAssertUniqueByKeyMessageEvalOnlyOnceOnFailure() throws
    {
        testMacroAssertionMessageEvalOnceOnFailure(.uniqueByKey)
    }
}
