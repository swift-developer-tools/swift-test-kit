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



internal final class ConfigurationTests: XCTestKitCase
{
    func testGlobalConfigAssignment()
    {
        var options = XCTKConfig.global
        
        XCTKAssertEqual(options.diffEnabled, true)
        XCTKAssertEqual(options.diffOptions.maxRecursionDepth, 20)
        XCTKAssertEqual(options.formatOptions.maxLineLength, 80)
        
        options.diffEnabled                     = false
        options.diffOptions.maxRecursionDepth   = 1
        options.formatOptions.maxLineLength     = 40

        XCTKConfig.global = options
        
        XCTKAssertEqual(options.diffEnabled, false)
        XCTKAssertEqual(XCTKConfig.global.diffOptions.maxRecursionDepth, 1)
        XCTKAssertEqual(XCTKConfig.global.formatOptions.maxLineLength, 40)
    }
    
    
    
    func testGlobalConfigReturnsDefaultOptions()
    {
        let options = XCTKConfig.global
        
        XCTKAssertEqual(options.diffEnabled, true)
        XCTKAssertEqual(options.diffOptions, DiffOptions())
        XCTKAssertEqual(options.formatOptions, FormatOptions())
    }
    
    
    
    func testGlobalConfigDirectModification()
    {
        XCTKAssertTrue(XCTKConfig.global.diffEnabled)
        
        XCTKConfig.global.diffEnabled = false
        
        XCTKAssertFalse(XCTKConfig.global.diffEnabled)
    }
    
    
    
    func testXCTKCaseReflectsGlobalOptions()
    {
        let testCase = XCTKCase()
        
        XCTKAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 20)
        
        XCTKConfig.global.diffOptions.maxRecursionDepth = 1
        
        XCTKAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 1)
    }
    
    
    
    func testXCTKCaseReturnsGlobalOptions()
    {
        let testCase = XCTKCase()
        
        XCTKAssertEqual(testCase.options, XCTKConfig.global)
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
        
        XCTKConfig.global.diffOptions.maxRecursionDepth = 5
        
        let customCase = CustomCase()
        
        XCTKAssertEqual(customCase.options.diffOptions.maxRecursionDepth, 1)
        XCTKAssertEqual(XCTKConfig.global.diffOptions.maxRecursionDepth, 5)
    }
    
    
    
    func testAssertionOptionsOverridePrecedence()
    {
        XCTKConfig.global.diffEnabled = true
        
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
}
