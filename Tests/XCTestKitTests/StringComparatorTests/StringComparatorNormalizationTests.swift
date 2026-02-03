//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
@testable import XCTestKit
@testable import XCTestKitTestUtilities



internal final class StringComparatorNormalizationTests: XCTestKitCase
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
        
        XCTKAssertEqual(expected, actual)
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
        
        XCTKAssertEqual(expected, actual)
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
        
        XCTKAssertEqual(expected, actual)
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
        
        XCTKAssertEqual(expected, actual)
    }
}
