//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TKTestSupport



internal final class FunctionAssertionOptionsTests: XCTestKitCase
{
    // MARK: - Equality and inequality
    
    func testAssertEqualOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.equal)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertSatisfyAllOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.satisfyAll)
    }
    
    
    
    func testAssertSatisfyAnyOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.satisfyAny)
    }
    
    
    
    func testAssertSatisfyNoneOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.satisfyNone)
    }
    
    
    
    func testAssertSatisfyAtLeastOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.satisfyAtLeast)
    }
    
    
    
    func testAssertSatisfyAtMostOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.satisfyAtMost)
    }
    
    
    
    func testAssertSatisfyRangeOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.satisfyRange)
    }
    
    
    
    func testAssertExactlyOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.exactly)
    }
    
    
    
    func testAssertExactlyOneOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.exactlyOne)
    }
    
    
    
    func testAssertUniqueBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.unique)
    }
    
    
    
    func testAssertUniqueByKeyBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.uniqueByKey)
    }
}
