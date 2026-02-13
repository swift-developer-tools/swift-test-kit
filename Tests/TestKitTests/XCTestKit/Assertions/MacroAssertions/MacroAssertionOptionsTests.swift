//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class MacroAssertionOptionsTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.assert)
    }
    
    
    
    func testAssertTrueOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.true)
    }
    
    
    
    func testAssertFalseOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.false)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.equal)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.satisfyRange)
    }
    
    
    
    func testAssertExactlyOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.exactly)
    }
    
    
    
    func testAssertExactlyOneOptionsBehavior()
    {
        testMacroAssertionOptionsBehavior(.exactlyOne)
    }
    
    
    
    func testAssertUniqueBehavior()
    {
        testMacroAssertionOptionsBehavior(.unique)
    }
    
    
    
    func testAssertUniqueByKeyBehavior()
    {
        testMacroAssertionOptionsBehavior(.uniqueByKey)
    }
}
