//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal final class FunctionAssertionOptionsTests: TestKitCase
{
    // MARK: - Equality and inequality
    
    func testAssertEqualOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.equal)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.satisfyRange)
    }
    
    
    
    func testAssertExactlyOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.exactly)
    }
    
    
    
    func testAssertExactlyOneOptionsBehavior()
    {
        assertFuncAssertionOptionsBehavior(.exactlyOne)
    }
    
    
    
    func testAssertUniqueBehavior()
    {
        assertFuncAssertionOptionsBehavior(.unique)
    }
    
    
    
    func testAssertUniqueByKeyBehavior()
    {
        assertFuncAssertionOptionsBehavior(.uniqueByKey)
    }
}
