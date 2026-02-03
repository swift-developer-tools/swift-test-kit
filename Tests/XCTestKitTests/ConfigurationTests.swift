//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore
@testable import XCTestKit
@testable import TKTestUtilities



internal final class ConfigurationTests: XCTestKitCase
{
    func testGlobalConfigAssignment() throws
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
    
    
    
    func testGlobalConfigReturnsDefaultOptions() throws
    {
        let options = XCTKConfig.global
        
        XCTKAssertEqual(options.diffEnabled, true)
        XCTKAssertEqual(options.diffOptions, TKDiffOptions())
        XCTKAssertEqual(options.formatOptions, TKFormatOptions())
    }
    
    
    
    func testGlobalConfigDirectModification() throws
    {
        XCTKAssertTrue(XCTKConfig.global.diffEnabled)
        
        XCTKConfig.global.diffEnabled = false
        
        XCTKAssertFalse(XCTKConfig.global.diffEnabled)
    }
    
    
    
    func testXCTKCaseReflectsGlobalOptions() throws
    {
        let testCase = XCTKCase()
        
        XCTKAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 20)
        
        XCTKConfig.global.diffOptions.maxRecursionDepth = 1
        
        XCTKAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 1)
    }
    
    
    
    func testXCTKCaseReturnsGlobalOptions() throws
    {
        let testCase = XCTKCase()
        
        XCTKAssertEqual(testCase.options, XCTKConfig.global)
    }
    
    
    
    func testXCTKCaseSubclassOverridePrecedence() throws
    {
        class CustomCase: XCTKCase
        {
            override var options: TKOptions
            {
                var opts = TKOptions()
                
                opts.diffOptions.maxRecursionDepth = 1
                
                return opts
            }
        }
        
        XCTKConfig.global.diffOptions.maxRecursionDepth = 5
        
        let customCase = CustomCase()
        
        XCTKAssertEqual(customCase.options.diffOptions.maxRecursionDepth, 1)
        XCTKAssertEqual(XCTKConfig.global.diffOptions.maxRecursionDepth, 5)
    }
    
    
    
    func testAssertionOptionsOverridePrecedence() throws
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
    
    
    
    func testTKOptions() throws
    {
        let options = TKOptions()
        
        XCTKAssertEqual(options.diffOptions, TKDiffOptions())
        XCTKAssertEqual(options.formatOptions, TKFormatOptions())
    }
    
    
    
    func testTKDiffOptions() throws
    {
        let options = TKDiffOptions()
        
        XCTKAssertEqual(options.maxRecursionDepth, 20)
        XCTKAssertNil(options.characterDiffThreshold)
    }
    
    
    
    func testTKFormatOptions() throws
    {
        let options = TKFormatOptions()
        
        XCTKAssertEqual(options.indentationSpaces, 4)
        XCTKAssertEqual(options.maxLineLength, 80)
        XCTKAssertEqual(options.maxDiffs, nil)
        XCTKAssertEqual(options.countDiffs, false)
        XCTKAssertEqual(options.showAllEvaluated, true)
        XCTKAssertEqual(options.showNotEvaluatedCount, true)
    }
}
