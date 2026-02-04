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
    
    func testAssertOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.assert)
    }
    
    
    
    func testAssertTrueOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.true)
    }
    
    
    
    func testAssertFalseOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.false)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.equal)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.satisfyRange)
    }
    
    
    
    func testAssertExactlyOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.exactly)
    }
    
    
    
    func testAssertExactlyOneOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.exactlyOne)
    }
    
    
    
    func testAssertUniqueBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.unique)
    }
    
    
    
    func testAssertUniqueByKeyBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.uniqueByKey)
    }
}
