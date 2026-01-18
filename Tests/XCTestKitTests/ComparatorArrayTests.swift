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



final class ComparatorArrayTests: XCTestKitCase
{
    func testArrayHashableMissingElement() throws
    {
        let expected    : [String]  = ["a", "b", "c"]
        let actual      : [String]  = ["a", "b"]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(2))
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "c")
    }
    
    
    
    func testArrayHashableModifiedElement() throws
    {
        let expected    : [String]  = ["a", "b", "c"]
        let actual      : [String]  = ["a", "x", "c"]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(1))
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "b")
        XCTAssertEqual(act as? String, "x")
        XCTAssertEqual(childTree.count, 1)
        XCTAssertEqual(childTree[0].label, .character(0))
    }
    
    
    
    func testArrayHashableUnexpectedElement() throws
    {
        let expected    : [String]  = ["a", "b"]
        let actual      : [String]  = ["a", "b", "c"]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(2))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act as? String, "c")
    }
    
    
    
    func testArrayNonHashableFallback() throws
    {
        struct Item: Equatable
        {
            let id: Int
        }
        
        
        
        let expected    : [Item]    = [Item(id: 1), Item(id: 2), Item(id: 3)]
        let actual      : [Item]    = [Item(id: 1), Item(id: 0), Item(id: 3)]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(1))
        
        
        
        guard case let .different(_, _, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(childTree.count, 1)
        XCTAssertEqual(childTree[0].label, .property(name: "id"))
    }
    
    
    
    func testArrayInsertionAtStart() throws
    {
        let expected    : [String]  = ["a", "b", "c"]
        let actual      : [String]  = ["x", "a", "b", "c"]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(0))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act as? String, "x")
    }
    
    
    
    func testArrayRemovalAtStart() throws
    {
        let expected    : [String]  = ["x", "a", "b", "c"]
        let actual      : [String]  = ["a", "b", "c"]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(0))
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "x")
    }
    
    
    
    func testArrayNonHashableWithInsertion() throws
    {
        struct Item: Equatable
        {
            let id: Int
        }
        
        
        
        let expected: [Item] =
        [
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let actual: [Item] =
        [
            Item(id: 0),
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        /// Non-hashable arrays fall back to index-by-index comparison.
        /// If this were hashable, `CollectionDifference` would have considered
        /// only the first element of `actual` as unexpected. With an
        /// index-by-index comparison, the first element of `actual` is
        /// considered different than the first element of `expected`, and the
        /// fourth element of `actual` is considered unexpected.
        XCTAssertEqual(tree1.count, 4)
        XCTAssertEqual(tree1[0].label, .index(0))
        XCTAssertEqual(tree1[1].label, .index(1))
        XCTAssertEqual(tree1[2].label, .index(2))
        XCTAssertEqual(tree1[3].label, .index(3))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "id"))
        
        
        
        guard case let .unexpectedElement(act) = tree1[3].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree1[3].kind)")
            return
        }
        
        XCTAssertEqual((act as? Item)?.id, 3)
    }
    
    
    
    func testArrayHashableWithInsertion() throws
    {
        struct Item: Equatable, Hashable
        {
            let id: Int
        }
        
        
        
        let expected: [Item] =
        [
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let actual: [Item] =
        [
            Item(id: 0),
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(0))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual((act as? Item)?.id, 0)
    }
}
