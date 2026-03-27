//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Reasync
import TestKitCore
import XCTest



internal final class AtomicIntegrationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    @Reasync
    func testPassesWithEmptyBody() async
    {
        let body: () async throws -> Void = { }
        
        await TKAtomic
        {
            try await body()
        }
    }
    
    
    
    @Reasync
    func testFailsWithOneFailingAssertion() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
        }
        
        await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
    }
    
    
    
    @Reasync
    func testFailsWithMultipleFailingAssertions() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            TKAssertFalse(true)
            TKAssertEqual(1, 2)
        }
        
        await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
    }
    
    
    
    @Reasync
    func testFailsWhenBodyThrowsError() async
    {
        let body: () async throws -> Void =
        {
            throw TestError()
        }
        
        await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
    }
    
    
    
    @Reasync
    func testContinuesAfterFailingAssertion() async
    {
        var reachedEnd: Bool = false
        
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            
            reachedEnd = true
        }
        
        await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        XCTAssertTrue(reachedEnd)
    }
}
