//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class MacroAssertionOptionsTests: TestKitCase
{
    // MARK: - Boolean
    
    func testAssertOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.assert)
    }
    
    
    
    func testAssertTrueOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.true)
    }
    
    
    
    func testAssertFalseOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.false)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.equal)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.satisfyRange)
    }
    
    
    
    func testAssertExactlyOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.exactly)
    }
    
    
    
    func testAssertExactlyOneOptionsBehavior()
    {
        assertMacroAssertionOptionsBehavior(.exactlyOne)
    }
    
    
    
    func testAssertUniqueBehavior()
    {
        assertMacroAssertionOptionsBehavior(.unique)
    }
    
    
    
    func testAssertUniqueByKeyBehavior()
    {
        assertMacroAssertionOptionsBehavior(.uniqueByKey)
    }
}
