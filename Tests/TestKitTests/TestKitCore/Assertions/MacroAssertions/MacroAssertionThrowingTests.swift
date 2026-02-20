//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class MacroAssertionThrowingTests: TestKitCase
{
    // MARK: - Boolean
    
    func testAssertFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.assert)
    }
    
    
    
    func testAssertTrueFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.true)
    }
    
    
    
    func testAssertFalseFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.false)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.nil)
    }
    
    
    
    func testAssertNotNilFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.notNil)
    }
    
    
    
    func testUnwrapFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.equal)
    }
    
    
    
    func testAssertNotEqualFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.notEqual)
    }
    
    
    
    func testAssertIdenticalFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.identical)
    }
    
    
    
    func testAssertNotIdenticalFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertEqualIntAccFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertNotEqualFloatAccFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.notEqualWithAccuracy )
    }
    
    
    
    func testAssertNotEqualIntAccFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.notEqualWithAccuracy)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertNoThrowFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.noThrow)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.satisfyRange)
    }
    
    
    
    func testAssertExactlyFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.exactly)
    }
    
    
    
    func testAssertExactlyOneFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.exactlyOne)
    }
    
    
    
    func testAssertSortedFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.sorted)
    }
    
    
    
    func testAssertUniqueFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.unique)
    }
    
    
    
    func testAssertUniqueByKeyFailsOnThrow()
    {
        assertMacroAssertionFailsOnThrow(.uniqueByKey)
    }
}
