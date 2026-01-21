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



final class StringComparatorCharCoalescingTests: XCTestKitCase
{
    func testCharCoalescingAdjacentRemovals() throws
    {
        let expected    : String    = "abcdef"
        let actual      : String    = "adef"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 1, count: 2))
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "bc")
    }
    
    
    
    func testCharCoalescingAdjacentInsertions() throws
    {
        let expected    : String    = "adef"
        let actual      : String    = "abcdef"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 1, count: 2))
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "bc")
    }
    
    
    
    func testCharCoalescingMixedChanges() throws
    {
        let expected    : String    = "abcdef"
        let actual      : String    = "aXXcYYf"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .character(index: 1, count: 1))
        XCTAssertEqual(tree[1].label, .character(index: 3, count: 2))
        
        print(tree)
        
        guard case let .different(exp1, act1, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "b")
        XCTAssertEqual(act1.value as? String, "XX")
        
        
        
        guard case let .different(exp2, act2, _) = tree[1].kind
        else
        {
            XCTFail("Expected .different, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "de")
        XCTAssertEqual(act2.value as? String, "YY")
    }
}
