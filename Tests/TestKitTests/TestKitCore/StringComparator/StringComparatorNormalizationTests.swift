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



internal final class StringComparatorNormalizationTests: XCTestCaseStopOnFail
{
    func testNewlineNormalizationCRLF() throws
    {
        let exp : String    = "line0\r\nline1"
        let act : String    = "line0\nline1"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNewlineNormalizationCR() throws
    {
        let exp : String    = "line0\rline1"
        let act : String    = "line0\nline1"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedNewlineNormalization() throws
    {
        let exp : String    = "line0\r\nline1\r\nline3"
        let act : String    = "line0\nline1\nline3"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedCRLFAndCRNormalization() throws
    {
        let exp : String    = "line0\r\nline1\rline3"
        let act : String    = "line0\nline1\nline3"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
}
