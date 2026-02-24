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



internal final class StatefulMessageTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    func testMessageNotEvalOnSuccess() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        await TKStateful(
            message(),
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    options
        )
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    func testMessageEvalOnceOnFailure() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               50
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                message(),
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    PropertyInterceptor.current?.recordFailure()
                }
            )
        }
        
        XCTAssertEqual(count, 1)
    }
    
    
    
    func testMessageEvalOnceOnExhaustion() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               50
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                message(),
                model:      { 0 },
                system:     { 0 },
                command:    RunDiscardCommand.self,
                options:    options
            )
        }
        
        XCTAssertEqual(count, 1)
    }
    
    
    
    func testMessageEvalOnceOnCoverageNotMet() async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               50
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                message(),
                model:      { 0 },
                system:     { 0 },
                command:    CoverNeverCommand.self,
                options:    options
            )
        }
        
        XCTAssertEqual(count, 1)
    }
}
