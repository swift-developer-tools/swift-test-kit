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



internal final class ConfigurationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        TestConfiguration.global = TestOptions()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    override func tearDown()
    {
        TestConfiguration.global = TestOptions()
        
        super.tearDown()
    }
    
    private typealias TC = TestConfiguration
    
    
    
    func testGlobalConfigAssignment()
    {
        var options = TC.global
        
        XCTKAssertEqual(options.diffEnabled, true)
        XCTKAssertEqual(options.diffOptions.maxRecursionDepth, 20)
        XCTKAssertEqual(options.formatOptions.maxLineLength, 80)
        
        options.diffEnabled                     = false
        options.diffOptions.maxRecursionDepth   = 1
        options.formatOptions.maxLineLength     = 40

        TC.global = options
        
        XCTKAssertEqual(options.diffEnabled, false)
        XCTKAssertEqual(TC.global.diffOptions.maxRecursionDepth, 1)
        XCTKAssertEqual(TC.global.formatOptions.maxLineLength, 40)
    }
    
    
    
    func testGlobalConfigReturnsDefaultOptions()
    {
        let options = TC.global
        
        XCTKAssertEqual(options.diffEnabled, true)
        XCTKAssertEqual(options.diffOptions, DiffOptions())
        XCTKAssertEqual(options.formatOptions, FormatOptions())
    }
    
    
    
    func testGlobalConfigDirectModification()
    {
        XCTKAssertTrue(TC.global.diffEnabled)
        
        TC.global.diffEnabled = false
        
        XCTKAssertFalse(TC.global.diffEnabled)
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
    
    
    
    @Reasync
    func testExplicitOptionsOverrideGlobal() async
    {
        /// With `iterations` set to zero, the property vacuously passes.
        TC.global.propertyOptions.iterations = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        let property: (Int) async throws -> Void =
        {
            _ async in

            TKAssertTrue(false)
        }
        
        let output: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (n: Int) async throws in
                
                try await property(n)
            }
        }
        
        XCTAssertNotNil(output)
    }
}
