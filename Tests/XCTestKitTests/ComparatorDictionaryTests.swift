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



final class ComparatorDictionaryTests: XCTestKitCase
{
    func testDictionaryEqualValues() throws
    {
        let expected: [String : Int] = ["a": 1, "b": 2, "c": 3]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard node.kind.isSame
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testDictionaryDifferentValue() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2]
        let actual      : [String : Int]    = ["a": 1, "b": 0]
        
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
        
        XCTAssertEqual(
            tree1[0].label,
            .key(description: "b", typeName: "String")
        )
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 2)
        XCTAssertEqual(act.value as? Int, 0)
        XCTAssertTrue(tree2.isEmpty)
    }
    
    
    
    func testsDictionaryMultipleDifferentValues() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2, "c": 3]
        let actual      : [String : Int]    = ["a": 1, "b": 4, "c": 6]
        
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "b", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "c", typeName: "String")
        )
    }
    
    
    
    func testDictionaryMissingEntry() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2]
        let actual      : [String : Int]    = ["a": 1]
        
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "b", typeName: "String")
        )
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 2)
    }
    
    
    
    func testDictionaryMultipleMissingEntries() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2, "c": 3, "d": 4]
        let actual      : [String : Int]    = ["a": 1]
        
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
        
        XCTAssertEqual(tree.count, 3)
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "b", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "c", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[2].label,
            .key(description: "d", typeName: "String")
        )
        
        
        
        for node in tree
        {
            guard node.kind.isMissing
            else
            {
                XCTFail("Expected .missing, got \(node.kind)")
                return
            }
        }
    }
    
    
    
    func testDictionaryUnexpectedEntry() throws
    {
        let expected    : [String : Int]    = ["a": 1]
        let actual      : [String : Int]    = ["a": 1, "b": 2]
        
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "b", typeName: "String")
        )
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? Int, 2)
    }
    
    
    
    func testDictionaryMultipleUnexpectedEntries() throws
    {
        let expected    : [String : Int]    = ["a": 1]
        let actual      : [String : Int]    = ["a": 1, "b": 2, "c": 3, "d": 4]
        
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
        
        XCTAssertEqual(tree.count, 3)
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "b", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "c", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[2].label,
            .key(description: "d", typeName: "String")
        )
        
        
        
        for node in tree
        {
            guard node.kind.isUnexpected
            else
            {
                XCTFail("Expected .unexpected, got \(node.kind)")
                return
            }
        }
    }
    
    
    
    func testDictionaryMixedChanges() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2, "c": 3]
        let actual      : [String : Int]    = ["a": 1, "c": 9, "d": 4]
        
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
        
        XCTAssertEqual(tree.count, 3)
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "b", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "c", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[2].label,
            .key(description: "d", typeName: "String")
        )
        
        
        
        guard case let .missing(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? Int, 2)
        
        

        guard case let .different(exp2, act2, _) = tree[1].kind
        else
        {
            XCTFail("Expected .different, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? Int, 3)
        XCTAssertEqual(act2.value as? Int, 9)
        
        
        
        guard case let .unexpected(act3) = tree[2].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[2].kind)")
            return
        }
        
        XCTAssertEqual(act3.value as? Int, 4)
    }
    
    
    
    func testDictionaryIntegerKeyOrdering() throws
    {
        /// `String(describing:)` produces: `"1", "2", "10", "20"`.
        /// Lexographic sort: `"10" < "2" < "20"`
        
        let expected    : [Int : String]    = [1: "a", 2: "b", 10: "c", 20: "d"]
        let actual      : [Int : String]    = [1: "a"]
        
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
        
        XCTAssertEqual(tree.count, 3)
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "10", typeName: "Int")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "2", typeName: "Int")
        )
        
        XCTAssertEqual(
            tree[2].label,
            .key(description: "20", typeName: "Int")
        )
    }
    
    
    
    func testDictionaryEmptyVsNonEmpty() throws
    {
        let expected    : [String : Int]    = [:]
        let actual      : [String : Int]    = ["a": 1, "b": 2]
        
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "a", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "b", typeName: "String")
        )
        
        
        
        guard case let .unexpected(act1) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act1.value as? Int, 1)
        
        
        
        guard case let .unexpected(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? Int, 2)
    }
    
    
    
    func testDictionaryNonEmptyVsEmpty() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2]
        let actual      : [String : Int]    = [:]
        
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "a", typeName: "String")
        )
        
        XCTAssertEqual(
            tree[1].label,
            .key(description: "b", typeName: "String")
        )
        
        
        
        guard case let .missing(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? Int, 1)
        
        
        
        guard case let .missing(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? Int, 2)
    }
    
    
    
    func testDictionaryBothEmpty() throws
    {
        let expected: [String : Int] = [:]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard node.kind.isSame
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testDictionaryWithOptionalValues() throws
    {
        let expected    : [String : Int?]   = ["a": 1, "b": nil, "c": 3]
        let actual      : [String : Int?]   = ["a": 1, "b": 2, "c": 3]
        
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
        
        XCTAssertEqual(
            tree1[0].label,
            .key(description: "b", typeName: "String")
        )
        
        
        
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
    
    
    
    func testDictionaryOfArrays() throws
    {
        let expected: [String : [Int]] =
        [
            "evens" : [2, 4, 6],
            "odds"  : [1, 3, 5]
        ]
        
        let actual: [String : [Int]] =
        [
            "evens" : [2, 4, 6],
            "odds"  : [1, 3, 7]
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
        
        XCTAssertEqual(
            tree1[0].label,
            .key(description: "odds", typeName: "String")
        )
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .index(2))
        
        
        
        guard case let .different(exp, act, _) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 5)
        XCTAssertEqual(act.value as? Int, 7)
    }
    
    
    
    func testDictionaryOfSets() throws
    {
        let expected: [String : Set<Int>] =
        [
            "primes"    : [2, 3, 5],
            "evens"     : [2, 4, 6]
        ]
        
        let actual: [String : Set<Int>] =
        [
            "primes"    : [2, 3, 5],
            "evens"     : [2, 4, 8]
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
        
        XCTAssertEqual(
            tree1[0].label,
            .key(description: "evens", typeName: "String")
        )
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 2)
        XCTAssertEqual(tree2[0].label, .member)
        XCTAssertEqual(tree2[1].label, .member)
        
        
        
        guard case let .missing(exp) = tree2[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 6)
        
        
        
        guard case let .unexpected(act) = tree2[1].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree2[1].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? Int, 8)
    }
    
    
    
    func testDictionaryWithCustomHashableKey() throws
    {
        struct UserID: Hashable
        {
            let id: Int
        }
        
        
        
        let expected: [UserID : String] =
        [
            UserID(id: 1): "a",
            UserID(id: 2): "b"
        ]
        
        let actual: [UserID : String] =
        [
            UserID(id: 1): "a",
            UserID(id: 2): "c"
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "UserID(id: 2)", typeName: "UserID")
        )
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "b")
        XCTAssertEqual(act.value as? String, "c")
    }
    
    
    
    func testDictionaryWithCustomHashableKeyMissingEntry() throws
    {
        struct Point: Hashable
        {
            let x   : Int
            let y   : Int
        }
        
        
        
        let expected: [Point : String] =
        [
            Point(x: 0, y: 0): "origin",
            Point(x: 1, y: 1): "diagonal"
        ]
        
        let actual: [Point : String] =
        [
            Point(x: 0, y: 0): "origin"
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "Point(x: 1, y: 1)", typeName: "Point")
        )
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "diagonal")
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
        
        
        
        let expected: [Direction : Int] =
        [
            .north  : 0,
            .south  : 180
        ]
        
        let actual: [Direction : Int] =
        [
            .north  : 0,
            .south  : 180,
            .east   : 90
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
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "east", typeName: "Direction")
        )
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? Int, 90)
    }
}
