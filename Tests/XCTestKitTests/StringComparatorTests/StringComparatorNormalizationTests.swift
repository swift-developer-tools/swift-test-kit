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



final class StringComparatorNormalizationTests: XCTestKitCase
{
    func testNewlineNormalizationCRLF() throws
    {
        let expected    : String    = "line0\r\nline1"
        let actual      : String    = "line0\nline1"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testNewlineNormalizationCR() throws
    {
        let expected    : String    = "line0\rline1"
        let actual      : String    = "line0\nline1"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testMixedNewlineNormalization() throws
    {
        let expected    : String    = "line0\r\nline1\r\nline3"
        let actual      : String    = "line0\nline1\nline3"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testMixedCRLFAndCRNormalization() throws
    {
        let expected    : String    = "line0\r\nline1\rline3"
        let actual      : String    = "line0\nline1\nline3"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
}
