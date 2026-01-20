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



final class StringComparatorCharThresholdTests: XCTestKitCase
{
    func testCharDiffThresholdCollapsesWhenExceeded() throws
    {
        let expected    : String    = "12345"
        let actual      : String    = "54321"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.75)
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testCharDiffThresholdPreservesWhenNotExceeded() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "hallo"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.75)
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(1))
    }
    
    
    
    func testCharDiffThresholdWithEmptyStrings() throws
    {
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   "",
            actual:     "",
            options:    XCTKDiffOptions(characterDiffThreshold: 0.5)
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testCharDiffThresholdAtExactBoundary() throws
    {
        /// Exactly 50% of characters are changed, and the threshold is 50%.
        /// The character diff must be preserved. The changes will be
        /// coalesced into a single node, however, rather than emitting one
        /// node for each changed character, since the changes are adjacent.
        let expected    : String    = "abcd"
        let actual      : String    = "abXX"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.5)
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(2))
    }
    
    
    
    func testCharDiffThresholdCompletelyDifferentWithThreshold() throws
    {
        let expected    : String    = "abc"
        let actual      : String    = "xyz"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.9)
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testCharDiffThresholdCompletelyDifferentNoThreshold() throws
    {
        let expected    : String    = "abc"
        let actual      : String    = "xyz"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        /// The diff will produce removed `{0, 1, 2}` and inserted `{0, 1, 2}`.
        /// At index `0`, both have entries, so the coalescing logic will
        /// accumulate all three characters in each of `expected` and `actual`,
        /// since there are entries at each index. The tree will contain the
        /// single coalesced node.
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(0))
    }
    
    
    
    func testThresholdAppliesToIndividualLines() throws
    {
        let expected    : String    = "keep\n12345\nkeep"
        let actual      : String    = "keep\n54321\nkeep"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.5)
        )
        
        guard case let .different(_, _, tree1) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .line(1))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "12345")
        XCTAssertEqual(act.value as? String, "54321")
        XCTAssertTrue(tree2.isEmpty)
    }
}
