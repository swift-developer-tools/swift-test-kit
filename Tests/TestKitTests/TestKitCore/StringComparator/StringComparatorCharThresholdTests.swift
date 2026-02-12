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



internal final class StringComparatorCharThresholdTests: XCTestCaseStopOnFail
{
    func testCharDiffThresholdCollapsesWhenExceeded() throws
    {
        let exp : String    = "12345"
        let act : String    = "54321"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act,
            options:    .init(characterDiffThreshold: 0.75)
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:       []
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharDiffThresholdPreservesWhenNotExceeded() throws
    {
        let exp : String    = "hello"
        let act : String    = "hallo"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act,
            options:    .init(characterDiffThreshold: 0.75)
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 1, count: 1),
                    expected:   "e",
                    actual:     "a"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharDiffThresholdWithEmptyStrings() throws
    {
        let exp: String = ""
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     exp,
            options:    .init(characterDiffThreshold: 0.5)
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharDiffThresholdAtExactBoundary() throws
    {
        /// Exactly 50% of characters are changed, and the threshold is 50%.
        /// The character diff must be preserved. The changes will be
        /// coalesced into a single node, however, rather than emitting one
        /// node for each changed character, since the changes are adjacent.
        
        let exp : String    = "abcd"
        let act : String    = "abXX"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act,
            options:    .init(characterDiffThreshold: 0.5)
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 2, count: 2),
                    expected:   "cd",
                    actual:     "XX"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharDiffThresholdCompletelyDifferentWithThreshold() throws
    {
        let exp : String    = "abc"
        let act : String    = "xyz"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act,
            options:    .init(characterDiffThreshold: 0.9)
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:       []
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharDiffThresholdCompletelyDifferentNoThreshold() throws
    {
        /// The diff will produce removed `{0, 1, 2}` and inserted `{0, 1, 2}`.
        /// At index `0`, both have entries, so the coalescing logic will
        /// accumulate all three characters in each of `expected` and `actual`,
        /// since there are entries at each index. The tree will contain the
        /// single coalesced node.
        
        let exp : String    = "abc"
        let act : String    = "xyz"
        
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
                    label:      .character(index: 0, count: 3),
                    expected:   exp,
                    actual:     act
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testThresholdAppliesToIndividualLines() throws
    {
        let exp : String    = "keep\n12345\nkeep"
        let act : String    = "keep\n54321\nkeep"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act,
            options:    .init(characterDiffThreshold: 0.5)
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .line(1),
                    expected:   "12345",
                    actual:     "54321"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
