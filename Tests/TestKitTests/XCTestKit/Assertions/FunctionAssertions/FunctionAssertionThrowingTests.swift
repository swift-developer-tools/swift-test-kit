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
        assertFuncAssertionFailsOnThrow(.assert)
    }
    
    
    
    func testAssertTrueFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.true)
    }
    
    
    
    func testAssertFalseFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.nil)
    }
    
    
    
    func testAssertNotNilFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.notNil)
    }
    
    
    
    func testUnwrapFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.equal)
    }
    
    
    
    func testAssertNotEqualFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.notEqual)
    }
    
    
    
    func testAssertIdenticalFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.identical)
    }
    
    
    
    func testAssertNotIdenticalFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertEqualIntAccFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertNotEqualFloatAccFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.notEqualWithAccuracy )
    }
    
    
    
    func testAssertNotEqualIntAccFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.notEqualWithAccuracy)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertNoThrowFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.noThrow)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.satisfyRange)
    }
    
    
    
    func testAssertExactlyFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.exactly)
    }
    
    
    
    func testAssertExactlyOneFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.exactlyOne)
    }
    
    
    
    func testAssertSortedFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.sorted)
    }
    
    
    
    func testAssertUniqueFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.unique)
    }
    
    
    
    func testAssertUniqueByKeyFailsOnThrow()
    {
        assertFuncAssertionFailsOnThrow(.uniqueByKey)
    }
}
