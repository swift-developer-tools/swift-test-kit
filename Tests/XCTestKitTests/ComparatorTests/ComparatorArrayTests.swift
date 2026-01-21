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
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "c")
    }
    
    
    
    func testArrayHashableModifiedElement() throws
    {
        let expected    : [String]  = ["a", "b", "c"]
        let actual      : [String]  = ["a", "x", "c"]
        
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
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .index(1))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "b")
        XCTAssertEqual(act.value as? String, "x")
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .character(index: 0, count: 1))
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
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "c")
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
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .index(1))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "id"))
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
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "x")
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
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "x")
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
        
        
        
        guard case let .unexpected(act) = tree1[3].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree1[3].kind)")
            return
        }
        
        XCTAssertEqual((act.value as? Item)?.id, 3)
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
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual((act.value as? Item)?.id, 0)
    }
    
    
    
    func testArrayOfMixedOptionals() throws
    {
        let expected    : [Int?]    = [1, nil, 3, nil]
        let actual      : [Int?]    = [1, 2, 3, nil]
        
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
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .index(1))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .unexpected(act) = tree2[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? Int, 2)
    }
    
    
    
    func testArrayWithDuplicateElements() throws
    {
        let expected    : [String]  = ["a", "a", "b", "c"]
        let actual      : [String]  = ["a", "b", "a", "c"]
        
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
        
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .index(1))
        XCTAssertEqual(tree[1].label, .index(2))
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "a")
        
        
        
        guard case let .unexpected(act) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "a")
    }
    
    
    
    func testArrayOfDictionaries() throws
    {
        let expected: [[String : Int]] =
        [
            ["a": 1, "b": 2],
            ["c": 3, "d": 4]
        ]
        
        let actual: [[String : Int]] =
        [
            ["a": 1, "b": 2],
            ["c": 3, "d": 99]
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
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .index(1))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        
        XCTAssertEqual(
            tree2[0].label,
            .key(description: "d", typeName: "String")
        )
        
        
        
        guard case let .different(exp, act, _) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 4)
        XCTAssertEqual(act.value as? Int, 99)
    }
    
    
    
    func testArrayOfSets() throws
    {
        let expected: [Set<String>] =
        [
            ["a", "b", "c"],
            ["x", "y", "z"]
        ]
        
        let actual: [Set<String>] =
        [
            ["a", "b", "c"],
            ["x", "y", "w"]
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
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .index(1))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 2)
        XCTAssertEqual(tree2[0].label, .member)
        XCTAssertEqual(tree2[1].label, .member)
        
        
        
        guard case let .unexpected(act) = tree2[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "w")
        
        
        
        guard case let .missing(exp) = tree2[1].kind
        else
        {
            XCTFail("Expected .missing, got \(tree2[1].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "z")
    }
}
