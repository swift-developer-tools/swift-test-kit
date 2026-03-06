//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



internal final class AtomicMessageTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    @Reasync
    func testMessageNotEvalOnSuccess() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let body: () async throws -> Void =
        {
            TKAssertTrue(true)
        }
        
        await TKAtomic(message())
        {
            try await body()
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    @Reasync
    func testMessageEvalOnceOnFailure() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
        }
        
        await withOneExpectedFailure
        {
            await TKAtomic(message())
            {
                try await body()
            }
        }
        
        XCTAssertEqual(count, 1)
    }
}
