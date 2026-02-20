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



internal final class OptionsTests: TestKitCase
{
    func testTestOptions()
    {
        let options = TestOptions()
        
        XCTAssertEqual(options.diffEnabled, true)
        XCTAssertEqual(options.diffOptions, DiffOptions())
        XCTAssertEqual(options.formatOptions, FormatOptions())
        XCTAssertEqual(options.propertyOptions, PropertyOptions())
    }
    
    
    
    func testDiffOptions()
    {
        let options = DiffOptions()
        
        XCTAssertEqual(options.maxRecursionDepth, 20)
        XCTAssertNil(options.characterDiffThreshold)
    }
    
    
    
    func testFormatOptions()
    {
        let options = FormatOptions()
        
        XCTAssertEqual(options.indentationSpaces, 4)
        XCTAssertEqual(options.maxLineLength, 80)
        XCTAssertEqual(options.maxDiffs, nil)
        XCTAssertEqual(options.countDiffs, false)
        XCTAssertEqual(options.showAllEvaluated, true)
        XCTAssertEqual(options.showNotEvaluatedCount, true)
    }
    
    
    
    func testPropertyOptions()
    {
        let options = PropertyOptions()
        
        XCTAssertEqual(options.iterations, 100)
        XCTAssertEqual(options.maxShrinkSteps, 100)
        XCTAssertEqual(options.maxSize, 100)
        XCTAssertEqual(options.maxDiscardRatio, 10)
        XCTAssertNil(options.seed)
    }
}
