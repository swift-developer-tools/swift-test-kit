//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit
@testable import XCTestKitTestUtilities



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
        XCTKAssertEqual(options.diffOptions, XCTKDiffOptions())
        XCTKAssertEqual(options.formatOptions, XCTKFormatOptions())
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
            override var options: XCTKOptions
            {
                var opts = XCTKOptions()
                
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
        
        XCTExpectFailure
        {
            return !$0.compactDescription.contains("differs at:")
        }
        
        XCTKAssertEqual(1, 2, options: XCTKOptions(diffEnabled: false))
    }
    
    
    
    func testXCTKOptions() throws
    {
        let options = XCTKOptions()
        
        XCTKAssertEqual(options.diffOptions, XCTKDiffOptions())
        XCTKAssertEqual(options.formatOptions, XCTKFormatOptions())
    }
    
    
    
    func testXCTKDiffOptions() throws
    {
        let options = XCTKDiffOptions()
        
        XCTKAssertEqual(options.maxRecursionDepth, 20)
        XCTKAssertNil(options.characterDiffThreshold)
    }
    
    
    
    func testXCTKFormatOptions() throws
    {
        let options = XCTKFormatOptions()
        
        XCTKAssertEqual(options.indentationSpaces, 4)
        XCTKAssertEqual(options.maxLineLength, 80)
        XCTKAssertEqual(options.maxDiffs, nil)
    }
}
