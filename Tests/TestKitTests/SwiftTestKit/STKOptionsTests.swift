//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftTestKit
import TestKitCore
import XCTest



internal final class STKOptionsTests: TestKitCase
{
    private typealias TC = TestConfiguration
    
    
    
    override func setUp()
    {
        super.setUp()
        
        TC.global = TestOptions()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    override func tearDown()
    {
        TC.global = TestOptions()
        
        super.tearDown()
    }
    
    
    
    func testAssertionOptionsOverridePrecedence()
    {
        TC.global.diffOptions.enabled = true
        
        let output1: String? = withOneExpectedFailure
        {
            STKAssertEqual(1, 2)
        }
        
        let output2: String? = withOneExpectedFailure
        {
            let options = TestOptions(diffOptions: .init(enabled: false))
            
            STKAssertEqual(1, 2, options: options)
        }
        
        STKAssertNotNil(output1)
        STKAssertNotNil(output2)
        STKAssertNotEqual(output1, output2)
    }
    
    
    
    @Reasync
    func testNilOptionsFallsBackToGlobal() async
    {
        /// With `iterations` set to zero, the property vacuously passes.
        TC.global.propertyOptions.iterations    = 0
        TC.global.propertyOptions.seed          = 50
        
        await STKForAll(options: nil)
        {
            (_: Int) async in
            
            STKAssertTrue(false)
        }
        
        TC.global.propertyOptions.iterations = 1
        
        let output: String? = await withOneExpectedFailure
        {
            await STKForAll(options: nil)
            {
                (_: Int) async in
                
                STKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
    }
}
