//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
import TKTestSupport
import XCTest



internal final class ComparatorDictionaryTests: XCTestCase
{
    func testDictionaryEqualValues() throws
    {
        let exp: [String : Int] = ["a": 1, "b": 2, "c": 3]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryDifferentValue() throws
    {
        let exp : [String : Int]    = ["a": 1, "b": 2]
        let act : [String : Int]    = ["a": 1, "b": 0]
        
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
                .makeLeaf(
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!,
                    actual:     act["b"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryMultipleDifferentValues() throws
    {
        let exp : [String : Int]    = ["a": 1, "b": 2, "c": 3]
        let act : [String : Int]    = ["a": 1, "b": 4, "c": 6]
        
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
                .makeLeaf(
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!,
                    actual:     act["b"]!
                ),
                
                .makeLeaf(
                    label:      .key("c", typeName: "String"),
                    expected:   exp["c"]!,
                    actual:     act["c"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryMissingEntry() throws
    {
        let exp : [String : Int]    = ["a": 1, "b": 2]
        let act : [String : Int]    = ["a": 1]
        
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
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryMultipleMissingEntries() throws
    {
        let exp : [String : Int]    = ["a": 1, "b": 2, "c": 3, "d": 4]
        let act : [String : Int]    = ["a": 1]
        
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
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!
                ),
                
                .makeMissing(
                    label:      .key("c", typeName: "String"),
                    expected:   exp["c"]!
                ),
            
                .makeMissing(
                    label:      .key("d", typeName: "String"),
                    expected:   exp["d"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryUnexpectedEntry() throws
    {
        let exp : [String : Int]    = ["a": 1]
        let act : [String : Int]    = ["a": 1, "b": 2]
        
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
                    label:      .key("b", typeName: "String"),
                    actual:     act["b"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryMultipleUnexpectedEntries() throws
    {
        let exp : [String : Int]    = ["a": 1]
        let act : [String : Int]    = ["a": 1, "b": 2, "c": 3, "d": 4]
        
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
                    label:      .key("b", typeName: "String"),
                    actual:     act["b"]!
                ),
                
                .makeUnexpected(
                    label:      .key("c", typeName: "String"),
                    actual:     act["c"]!
                ),
            
                .makeUnexpected(
                    label:      .key("d", typeName: "String"),
                    actual:     act["d"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryMixedChanges() throws
    {
        let exp : [String : Int]    = ["a": 1, "b": 2, "c": 3]
        let act : [String : Int]    = ["a": 1, "c": 9, "d": 4]
        
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
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!
                ),
                
                .makeLeaf(
                    label:      .key("c", typeName: "String"),
                    expected:   exp["c"]!,
                    actual:     act["c"]!
                ),
            
                .makeUnexpected(
                    label:      .key("d", typeName: "String"),
                    actual:     act["d"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryIntegerKeyOrdering() throws
    {
        /// `String(describing:)` produces: `"1", "2", "10", "20"`.
        /// Lexicoographic sort: `"10" < "2" < "20"`
        
        let exp : [Int : String]    = [1: "a", 2: "b", 10: "c", 20: "d"]
        let act : [Int : String]    = [1: "a"]
        
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
                    label:      .key("10", typeName: "Int"),
                    expected:   exp[10]!
                ),
                
                .makeMissing(
                    label:      .key("2", typeName: "Int"),
                    expected:   exp[2]!
                ),
            
                .makeMissing(
                    label:      .key("20", typeName: "Int"),
                    expected:   exp[20]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryEmptyVsNonEmpty() throws
    {
        let exp : [String : Int]    = [:]
        let act : [String : Int]    = ["a": 1, "b": 2]
        
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
                    label:      .key("a", typeName: "String"),
                    actual:     act["a"]!
                ),
                
                .makeUnexpected(
                    label:      .key("b", typeName: "String"),
                    actual:     act["b"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryNonEmptyVsEmpty() throws
    {
        let exp : [String : Int]    = ["a": 1, "b": 2]
        let act : [String : Int]    = [:]
        
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
                    label:      .key("a", typeName: "String"),
                    expected:   exp["a"]!
                ),
            
                .makeMissing(
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryBothEmpty() throws
    {
        let exp: [String : Int] = [:]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryWithOptionalValues() throws
    {
        let exp : [String : Int?]   = ["a": 1, "b": nil, "c": 3]
        let act : [String : Int?]   = ["a": 1, "b": 2, "c": 3]
        
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
                    label:      .key("b", typeName: "String"),
                    expected:   exp["b"]!,
                    actual:     act["b"]!,
                    tree:
                    [
                        .makeUnexpected(
                            label:  .property(name: "some"),
                            actual:     act["b"]!!
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryOfArrays() throws
    {
        let exp: [String : [Int]] =
        [
            "evens" : [2, 4, 6],
            "odds"  : [1, 3, 5]
        ]
        
        let act: [String : [Int]] =
        [
            "evens" : [2, 4, 6],
            "odds"  : [1, 3, 7]
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
                    label:      .key("odds", typeName: "String"),
                    expected:   exp["odds"]!,
                    actual:     act["odds"]!,
                    tree:
                    [
                        .makeLeaf(
                            label:      .index(2),
                            expected:   exp["odds"]![2],
                            actual:     act["odds"]![2]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryOfSets() throws
    {
        let exp: [String : Set<Int>] =
        [
            "primes"    : [2, 3, 5],
            "evens"     : [2, 4, 6]
        ]
        
        let act: [String : Set<Int>] =
        [
            "primes"    : [2, 3, 5],
            "evens"     : [2, 4, 8]
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
                    label:      .key("evens", typeName: "String"),
                    expected:   exp["evens"]!,
                    actual:     act["evens"]!,
                    tree:
                    [
                        .makeMissing(
                            label:      .member,
                            expected:   6
                        ),
                        
                        .makeUnexpected(
                            label:      .member,
                            actual:     8
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryWithCustomHashableKey() throws
    {
        struct User: Hashable
        {
            let id: Int
        }
        
        let exp: [User : String] =
        [
            User(id: 1): "a",
            User(id: 2): "b"
        ]
        
        let act: [User : String] =
        [
            User(id: 1): "a",
            User(id: 2): "c"
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
                    label:      .key("User(id: 2)", typeName: "User"),
                    expected:   exp[User(id: 2)]!,
                    actual:     act[User(id: 2)]!,
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   "b",
                            actual:     "c"
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryWithCustomHashableKeyMissingEntry() throws
    {
        struct Point: Hashable
        {
            let x   : Int
            let y   : Int
        }
        
        let exp: [Point : String] =
        [
            Point(x: 0, y: 0): "origin",
            Point(x: 1, y: 1): "diagonal"
        ]
        
        let act: [Point : String] =
        [
            Point(x: 0, y: 0): "origin"
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
                .makeMissing(
                    label:      .key("Point(x: 1, y: 1)", typeName: "Point"),
                    expected:   exp[Point(x: 1, y: 1)]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryWithEnumKey() throws
    {
        enum Direction: Hashable
        {
            case north
            case south
            case east
            case west
        }
        
        let exp: [Direction : Int] =
        [
            .north  : 0,
            .south  : 180
        ]
        
        let act: [Direction : Int] =
        [
            .north  : 0,
            .south  : 180,
            .east   : 90
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
                    label:      .key("east", typeName: "Direction"),
                    actual:     act[.east]!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
