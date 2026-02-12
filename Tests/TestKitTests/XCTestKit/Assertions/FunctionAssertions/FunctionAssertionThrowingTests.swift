//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class FunctionAssertionThrowingTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.assert)
    }
    
    
    
    func testAssertTrueFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.true)
    }
    
    
    
    func testAssertFalseFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.nil)
    }
    
    
    
    func testAssertNotNilFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.notNil)
    }
    
    
    
    func testUnwrapFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.equal)
    }
    
    
    
    func testAssertNotEqualFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.notEqual)
    }
    
    
    
    func testAssertIdenticalFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.identical)
    }
    
    
    
    func testAssertNotIdenticalFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertEqualIntAccFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertNotEqualFloatAccFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.notEqualWithAccuracy )
    }
    
    
    
    func testAssertNotEqualIntAccFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.notEqualWithAccuracy)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertNoThrowFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.noThrow)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.satisfyRange)
    }
    
    
    
    func testAssertExactlyFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.exactly)
    }
    
    
    
    func testAssertExactlyOneFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.exactlyOne)
    }
    
    
    
    func testAssertSortedFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.sorted)
    }
    
    
    
    func testAssertUniqueFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.unique)
    }
    
    
    
    func testAssertUniqueByKeyFailsOnThrow() throws
    {
        testFunctionAssertionFailsOnThrow(.uniqueByKey)
    }
}
