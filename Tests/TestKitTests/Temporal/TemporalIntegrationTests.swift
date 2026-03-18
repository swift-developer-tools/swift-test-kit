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



internal final class TemporalIntegrationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    func testEventuallyPassesOnLaterPoll() async
    {
        let count = Mutex<Int>(0)
        
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(200),
            interval:   .milliseconds(10)
        )
        
        await TKEventually(options: options)
        {
            let n: Int = count.withLock
            {
                $0 += 1
                return $0
            }
            
            TKAssertGreaterThanOrEqual(n, 3)
        }
    }
    
    
    
    func testEventuallyPassesImmediately() async
    {
        await TKEventually
        {
            TKAssertTrue(true)
        }
    }
    
    
    
    func testAlwaysFailsImmediately() async
    {
        await withOneExpectedFailure
        {
            await TKAlways
            {
                TKAssertTrue(false)
            }
        }
    }
    
    
    
    func testAlwaysPassesForFullDuration() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        await TKAlways(options: options)
        {
            TKAssertTrue(true)
        }
    }
}
