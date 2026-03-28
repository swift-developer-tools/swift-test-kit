//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class FormatterPathTests: TestKitCase
{
    private typealias LK = TestKitCore.Formatter.LabelKind
    
    
    
    func testPropertyPath()
    {
        struct User: Equatable
        {
            let age: Int
        }
        
        let exp         : User      = .init(age: 30)
        let act         : User      = .init(age: 25)
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "age"),
                    expected:   exp.age,
                    actual:     act.age
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .age
                \(LK.expected.rawValue)\(exp.age)
                \(LK.actual.rawValue)\(act.age)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedPropertyPath()
    {
        struct Inner: Equatable
        {
            let value: Int
        }
        
        struct Outer: Equatable
        {
            let inner: Inner
        }
        
        let exp         : Outer     = .init(inner: Inner(value: 10))
        let act         : Outer     = .init(inner: Inner(value: 20))
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "inner"),
                    expected:   exp.inner,
                    actual:     act.inner,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "value"),
                            expected:   exp.inner.value,
                            actual:     act.inner.value
                        )
                    ]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .inner.value
                \(LK.expected.rawValue)\(exp.inner.value)
                \(LK.actual.rawValue)\(act.inner.value)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedNestedPath()
    {
        struct Item: Equatable
        {
            let name: String
        }
        
        let exp         : [Item]    = [Item(name: "a")]
        let act         : [Item]    = [Item(name: "b")]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(0),
                    expected:   exp[0],
                    actual:     act[0],
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "name"),
                            expected:   exp[0].name,
                            actual:     act[0].name
                        )
                    ]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0].name
                \(LK.expected.rawValue)\(quote(exp[0].name))
                \(LK.actual.rawValue)\(quote(act[0].name))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDeeplyNestedPath()
    {
        struct L4: Equatable { let val  : Int }
        struct L3: Equatable { let l4   : L4 }
        struct L2: Equatable { let l3   : L3 }
        struct L1: Equatable { let l2   : L2 }
        
        let exp         : L1        = .init(l2: L2(l3: L3(l4: L4(val: 1))))
        let act         : L1        = .init(l2: L2(l3: L3(l4: L4(val: 2))))
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "l2"),
                    expected:   exp.l2,
                    actual:     act.l2,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "l3"),
                            expected:   exp.l2.l3,
                            actual:     act.l2.l3,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "l4"),
                                    expected:   exp.l2.l3.l4,
                                    actual:     act.l2.l3.l4,
                                    tree:
                                    [
                                        .makeStructural(
                                            label:      .property(name: "val"),
                                            expected:   exp.l2.l3.l4.val,
                                            actual:     act.l2.l3.l4.val,
                                            tree:       []
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .l2.l3.l4.val
                \(LK.expected.rawValue)\(exp.l2.l3.l4.val)
                \(LK.actual.rawValue)\(act.l2.l3.l4.val)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testIndexPath()
    {
        let exp         : [Int]     = [1, 2, 3]
        let act         : [Int]     = [1, 0, 3]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .index(1),
                    expected:   exp[1],
                    actual:     act[1]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [1]
                \(LK.expected.rawValue)\(exp[1])
                \(LK.actual.rawValue)\(act[1])
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testKeyPath()
    {
        let exp         : [String : Int]    = ["a": 1]
        let act         : [String : Int]    = ["a": 2]
        let typeName    : String            = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .key("a", typeName: "String"),
                    expected:   exp["a"]!,
                    actual:     act["a"]!
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            ["a"]
                \(LK.expected.rawValue)\(exp["a"]!)
                \(LK.actual.rawValue)\(act["a"]!)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryKeyNestedWithProperty()
    {
        struct Item: Equatable
        {
            let count: Int
        }
        
        let exp         : [String : Item]   = ["key": Item(count: 10)]
        let act         : [String : Item]   = ["key": Item(count: 20)]
        let typeName    : String            = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .key("key", typeName: "String"),
                    expected:   exp["key"]!,
                    actual:     act["key"]!,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "count"),
                            expected:   exp["key"]!.count,
                            actual:     act["key"]!.count
                        )
                    ]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            ["key"].count
                \(LK.expected.rawValue)\(exp["key"]!.count)
                \(LK.actual.rawValue)\(act["key"]!.count)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testLinePath()
    {
        let exp         : String    = "line1\nline2"
        let act         : String    = "line1\nchanged"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .line(1),
                    expected:   "line2",
                    actual:     "changed"
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            line 2
                \(LK.expected.rawValue)"line2"
                \(LK.actual.rawValue)"changed"
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharacterPath()
    {
        let exp         : String    = "hello"
        let act         : String    = "hallo"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 1, count: 1),
                    expected:   "e",
                    actual:     "a"
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            character 2
                \(LK.expected.rawValue)"e"
                \(LK.actual.rawValue)"a"
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testLineAndCharacterPath()
    {
        let exp         : String    = "line1\nhello"
        let act         : String    = "line1\nhallo"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .line(1),
                    expected:   "hello",
                    actual:     "hallo"
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            line 2
                \(LK.expected.rawValue)"hello"
                \(LK.actual.rawValue)"hallo"
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleDifferencesAtSameLevel()
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        let exp         : User      = .init(name: "a", age: 30)
        let act         : User      = .init(name: "b", age: 25)
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "name"),
                    expected:   exp.name,
                    actual:     act.name
                ),
                
                .makeLeaf(
                    label:      .property(name: "age"),
                    expected:   exp.age,
                    actual:     act.age
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .name
                \(LK.expected.rawValue)\(quote(exp.name))
                \(LK.actual.rawValue)\(quote(act.name))

            .age
                \(LK.expected.rawValue)\(exp.age)
                \(LK.actual.rawValue)\(act.age)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedArrayIndices()
    {
        let exp         : [[Int]]   = [[1, 2], [3, 4]]
        let act         : [[Int]]   = [[1, 2], [3, 8]]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
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
                            label:      .index(1),
                            expected:   exp[1][1],
                            actual:     act[1][1]
                        )
                    ]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [1][1]
                \(LK.expected.rawValue)\(exp[1][1])
                \(LK.actual.rawValue)\(act[1][1])
        """
        
        XCTAssertEqual(expected, actual)
    }
}
