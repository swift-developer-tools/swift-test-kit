//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TKTestSupport
import XCTest



internal final class ComparatorArrayTests: XCTestCase
{
    func testArrayHashableMissingElement() throws
    {
        let exp : [String]  = ["a", "b", "c"]
        let act : [String]  = ["a", "b"]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .index(2),
                    expected:   exp[2]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayHashableModifiedElement() throws
    {
        let exp : [String]  = ["a", "b", "c"]
        let act : [String]  = ["a", "x", "c"]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(1),
                    expected:   exp[1],
                    actual:     act[1],
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   exp[1],
                            actual:     act[1]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayHashableUnexpectedElement() throws
    {
        let exp : [String]  = ["a", "b"]
        let act : [String]  = ["a", "b", "c"]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .index(2),
                    actual:     act[2]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayNonHashableFallback() throws
    {
        struct Item: Equatable
        {
            let id: Int
        }
        
        let exp : [Item]    = [Item(id: 1), Item(id: 2), Item(id: 3)]
        let act : [Item]    = [Item(id: 1), Item(id: 0), Item(id: 3)]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(1),
                    expected:   exp[1],
                    actual:     act[1],
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "id"),
                            expected:   exp[1].id,
                            actual:     act[1].id
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayInsertionAtStart() throws
    {
        let exp : [String]  = ["a", "b", "c"]
        let act : [String]  = ["x", "a", "b", "c"]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .index(0),
                    actual:     act[0]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayRemovalAtStart() throws
    {
        let exp : [String]  = ["x", "a", "b", "c"]
        let act : [String]  = ["a", "b", "c"]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .index(0),
                    expected:   exp[0]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)

    }
    
    
    
    func testArrayNonHashableWithInsertion() throws
    {
        struct Item: Equatable
        {
            let id: Int
        }
        
        let exp: [Item] =
        [
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let act: [Item] =
        [
            Item(id: 0),
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        /// Non-hashable arrays fall back to index-by-index comparison.
        /// If this were hashable, `CollectionDifference` would have considered
        /// only the first element of `act` as unexpected. With an
        /// index-by-index comparison, the first element of `act` is considered
        /// different than the first element of `exp`, and the fourth element
        /// of `act` is considered unexpected.
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       (0...3).map
            {
                i in
                
                if i < 3
                {
                    return .makeStructural(
                        label:      .index(i),
                        expected:   exp[i],
                        actual:     act[i],
                        tree:
                        [
                            .makeLeaf(
                                label:      .property(name: "id"),
                                expected:   exp[i].id,
                                actual:     act[i].id
                            )
                        ]
                    )
                }
                
                return .makeUnexpected(
                    label:      .index(i),
                    actual:     act[i]
                )
            }
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayHashableWithInsertion() throws
    {
        struct Item: Equatable, Hashable
        {
            let id: Int
        }
        
        let exp: [Item] =
        [
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let act: [Item] =
        [
            Item(id: 0),
            Item(id: 1),
            Item(id: 2),
            Item(id: 3)
        ]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .index(0),
                    actual:     act[0]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayOfMixedOptionals() throws
    {
        let exp : [Int?]    = [1, nil, 3, nil]
        let act : [Int?]    = [1, 2, 3, nil]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(1),
                    expected:   exp[1],
                    actual:     act[1],
                    tree:
                    [
                        .makeUnexpected(
                            label:      .property(name: "some"),
                            actual:     act[1]!
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayWithDuplicateElements() throws
    {
        let exp : [String]  = ["a", "a", "b", "c"]
        let act : [String]  = ["a", "b", "a", "c"]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .index(1),
                    expected:   exp[1]
                ),
                
                .makeUnexpected(
                    label:      .index(2),
                    actual:     act[2]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayOfDictionaries() throws
    {
        let exp: [[String : Int]] =
        [
            ["a": 1, "b": 2],
            ["c": 3, "d": 4]
        ]
        
        let act: [[String : Int]] =
        [
            ["a": 1, "b": 2],
            ["c": 3, "d": 99]
        ]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(1),
                    expected:   exp[1],
                    actual:     act[1],
                    tree:
                    [
                        .makeLeaf(
                            label:      .key("d", typeName: "String"),
                            expected:   exp[1]["d"]!,
                            actual:     act[1]["d"]!
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testArrayOfSets() throws
    {
        let exp: [Set<String>] =
        [
            ["a", "b", "c"],
            ["x", "y", "z"]
        ]
        
        let act: [Set<String>] =
        [
            ["a", "b", "c"],
            ["x", "y", "w"]
        ]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(1),
                    expected:   exp[1],
                    actual:     act[1],
                    tree:
                    [
                        .makeUnexpected(
                            label:      .member,
                            actual:     "w"
                        ),
                        
                        .makeMissing(
                            label:      .member,
                            expected:   "z"
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
