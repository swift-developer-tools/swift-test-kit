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



internal final class OptionsTests: XCTestCase
{
    func testTKOptions() throws
    {
        let options = TKOptions()
        
        XCTAssertEqual(options.diffOptions, TKDiffOptions())
        XCTAssertEqual(options.formatOptions, TKFormatOptions())
    }
    
    
    
    func testTKDiffOptions() throws
    {
        let options = TKDiffOptions()
        
        XCTAssertEqual(options.maxRecursionDepth, 20)
        XCTAssertNil(options.characterDiffThreshold)
    }
    
    
    
    func testTKFormatOptions() throws
    {
        let options = TKFormatOptions()
        
        XCTAssertEqual(options.indentationSpaces, 4)
        XCTAssertEqual(options.maxLineLength, 80)
        XCTAssertEqual(options.maxDiffs, nil)
        XCTAssertEqual(options.countDiffs, false)
        XCTAssertEqual(options.showAllEvaluated, true)
        XCTAssertEqual(options.showNotEvaluatedCount, true)
    }
}
