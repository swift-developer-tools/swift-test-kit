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
    
    func testAssertFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.assert)
    }
    
    
    
    func testAssertTrueFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.true)
    }
    
    
    
    func testAssertFalseFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.nil)
    }
    
    
    
    func testAssertNotNilFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.notNil)
    }
    
    
    
    func testUnwrapFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.equal)
    }
    
    
    
    func testAssertNotEqualFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.notEqual)
    }
    
    
    
    func testAssertIdenticalFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.identical)
    }
    
    
    
    func testAssertNotIdenticalFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertEqualIntAccFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertNotEqualFloatAccFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.notEqualWithAccuracy )
    }
    
    
    
    func testAssertNotEqualIntAccFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.notEqualWithAccuracy)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertNoThrowFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.noThrow)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.satisfyRange)
    }
    
    
    
    func testAssertExactlyFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.exactly)
    }
    
    
    
    func testAssertExactlyOneFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.exactlyOne)
    }
    
    
    
    func testAssertSortedFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.sorted)
    }
    
    
    
    func testAssertUniqueFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.unique)
    }
    
    
    
    func testAssertUniqueByKeyFailsOnThrow()
    {
        testFunctionAssertionFailsOnThrow(.uniqueByKey)
    }
}
