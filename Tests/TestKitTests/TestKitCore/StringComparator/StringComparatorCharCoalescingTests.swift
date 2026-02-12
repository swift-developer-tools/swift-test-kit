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



internal final class StringComparatorCharCoalescingTests: XCTestCaseStopOnFail
{
    func testCharCoalescingAdjacentRemovals() throws
    {
        let exp : String    = "abcdef"
        let act : String    = "adef"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeMissing(
                    label:      .character(index: 1, count: 2),
                    expected:   "bc"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharCoalescingAdjacentInsertions() throws
    {
        let exp : String    = "adef"
        let act : String    = "abcdef"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeUnexpected(
                    label:      .character(index: 1, count: 2),
                    actual:     "bc"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharCoalescingMixedChanges() throws
    {
        let exp : String    = "abcdef"
        let act : String    = "aXXcYYf"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 1, count: 1),
                    expected:   "b",
                    actual:     "XX"
                ),
                
                .makeLeaf(
                    label:      .character(index: 3, count: 2),
                    expected:   "de",
                    actual:     "YY"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
