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



// TODO: Test assertion-level options override class and global.
final class ConfigurationTests: XCTestKitCase
{
    func testGlobalConfigAssignment() throws
    {
        var options = XCTKConfig.global
        
        XCTAssertEqual(options.diffEnabled, true)
        XCTAssertEqual(options.diffOptions.maxRecursionDepth, 20)
        XCTAssertEqual(options.formatOptions.maxLineLength, 80)
        
        options.diffEnabled                     = false
        options.diffOptions.maxRecursionDepth   = 1
        options.formatOptions.maxLineLength      = 40

        XCTKConfig.global = options
        
        XCTAssertEqual(options.diffEnabled, false)
        XCTAssertEqual(XCTKConfig.global.diffOptions.maxRecursionDepth, 1)
        XCTAssertEqual(XCTKConfig.global.formatOptions.maxLineLength, 40)
    }
    
    
    
    func testGlobalConfigReturnsDefaultOptions() throws
    {
        let options = XCTKConfig.global
        
        XCTAssertEqual(options.diffEnabled, true)
        XCTAssertEqual(options.diffOptions, XCTKDiffOptions())
        XCTAssertEqual(options.formatOptions, XCTKFormatOptions())
    }
    
    
    
    func testGlobalConfigDirectModification() throws
    {
        XCTAssertTrue(XCTKConfig.global.diffEnabled)
        
        XCTKConfig.global.diffEnabled = false
        
        XCTAssertFalse(XCTKConfig.global.diffEnabled)
    }
    
    
    
    func testXCTKCaseReflectsGlobalOptions() throws
    {
        let testCase = XCTKCase()
        
        XCTAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 20)
        
        XCTKConfig.global.diffOptions.maxRecursionDepth = 1
        
        XCTAssertEqual(testCase.options.diffOptions.maxRecursionDepth, 1)
    }
    
    
    
    func testXCTKCaseReturnsGlobalOptions() throws
    {
        let testCase = XCTKCase()
        
        XCTAssertEqual(testCase.options, XCTKConfig.global)
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
        
        XCTAssertEqual(customCase.options.diffOptions.maxRecursionDepth, 1)
        XCTAssertEqual(XCTKConfig.global.diffOptions.maxRecursionDepth, 5)
    }
    
    
    
    func testXCTKOptions() throws
    {
        let options = XCTKOptions()
        
        XCTAssertEqual(options.diffOptions, XCTKDiffOptions())
        XCTAssertEqual(options.formatOptions, XCTKFormatOptions())
    }
    
    
    
    func testXCTKDiffOptions() throws
    {
        let options = XCTKDiffOptions()
        
        XCTAssertEqual(options.maxRecursionDepth, 20)
        XCTAssertNil(options.characterDiffThreshold)
    }
    
    
    
    func testXCTKFormatOptions() throws
    {
        let options = XCTKFormatOptions()
        
        XCTAssertEqual(options.indentationSpaces, 4)
        XCTAssertEqual(options.maxLineLength, 80)
        XCTAssertEqual(options.maxDiffs, nil)
    }
}
