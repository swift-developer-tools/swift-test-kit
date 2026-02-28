//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import Synchronization
import XCTest



internal final class TemporalMessageTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Always
    
    func testAlwaysMessageNotEvalOnSuccess() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        await TKAlways(message())
        {
            TKAssertTrue(true)
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    func testAlwaysMessageEvalOnceOnFailure() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        await withOneExpectedFailure
        {
            await TKAlways(message())
            {
                TKAssertTrue(false)
            }
        }
        
        XCTAssertEqual(count, 1)
    }
    
    
    
    // MARK: - Eventually
    
    func testEventuallyMessageNotEvalOnSuccess() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        await TKEventually(message())
        {
            TKAssertTrue(true)
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    func testEventuallyMessageEvalOnceOnFailure() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        await withCapturedFailure
        {
            context in
            
            await TKEventually(
                message(),
                context: context
            )
            {
                TKAssertTrue(false)
            }
        }
        
        XCTAssertEqual(count, 1)
    }
}
