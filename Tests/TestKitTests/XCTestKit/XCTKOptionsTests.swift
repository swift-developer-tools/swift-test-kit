//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



internal final class XCTKOptionsTests: TestKitCase
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
        TC.global.diffEnabled = true
        
        let output1: String? = withOneExpectedFailure
        {
            XCTKAssertEqual(1, 2)
        }
        
        let output2: String? = withOneExpectedFailure
        {
            XCTKAssertEqual(1, 2, options: .init(diffEnabled: false))
        }
        
        XCTKAssertNotNil(output1)
        XCTKAssertNotNil(output2)
        XCTKAssertNotEqual(output1, output2)
    }
    
    
    
    @Reasync
    func testNilOptionsFallsBackToGlobal() async
    {
        /// With `iterations` set to zero, the property vacuously passes.
        TC.global.propertyOptions.iterations    = 0
        TC.global.propertyOptions.seed          = 50
        
        await XCTKForAll(options: nil)
        {
            (_: Int) async in
            
            XCTKAssertTrue(false)
        }
        
        TC.global.propertyOptions.iterations = 1
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: nil)
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    func testXCTKCaseReflectsGlobalOptions()
    {
        let testCase = XCTKCase()
        
        XCTKAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 20)
        
        TC.global.diffOptions.maxRecursionDepth = 1
        
        XCTKAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 1)
    }
    
    
    
    func testXCTKCaseReturnsGlobalOptions()
    {
        let testCase = XCTKCase()
        
        XCTKAssertEqual(testCase.options, TC.global)
    }
    
    
    
    func testXCTKCaseSubclassOverridePrecedence()
    {
        class CustomCase: XCTKCase
        {
            override var options: TestOptions
            {
                var opts = TestOptions()
                
                opts.diffOptions.maxRecursionDepth = 1
                
                return opts
            }
        }
        
        TC.global.diffOptions.maxRecursionDepth = 5
        
        let customCase = CustomCase()
        
        XCTKAssertEqual(customCase.options.diffOptions.maxRecursionDepth, 1)
        XCTKAssertEqual(TC.global.diffOptions.maxRecursionDepth, 5)
    }
}
