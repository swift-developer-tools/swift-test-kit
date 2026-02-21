//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitCore



internal final class ComparatorStructTests: TestKitCase
{
    func testNestedStructs()
    {
        struct Address: Equatable
        {
            let city    : String
            let zip     : String
        }
        
        struct Person: Equatable
        {
            let name    : String
            let address : Address
        }
        
        let exp = Person(
            name:       "Someone",
            address:    Address(city: "Place", zip: "12345")
        )
        
        let act = Person(
            name:       "Someone",
            address:    Address(city: "Place", zip: "54321")
        )
        
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
                    label:      .property(name: "address"),
                    expected:   exp.address,
                    actual:     act.address,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "zip"),
                            expected:   exp.address.zip,
                            actual:     act.address.zip,
                            tree:
                            [
                                .makeMissing(
                                    label:      .character(index: 0, count: 4),
                                    expected:   "1234"
                                ),
                                
                                .makeUnexpected(
                                    label:      .character(index: 5, count: 4),
                                    actual:     "4321"
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStructEqualValues()
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        let exp = User(
            name:   "Someone",
            age:    10
        )
        
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
    
    
    
    func testStructSinglePropertyDifference()
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        let exp = User(
            name:   "Someone",
            age:    10
        )
        
        let act = User(
            name:   "Someone",
            age:    20
        )
        
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
                    label:      .property(name: "age"),
                    expected:   exp.age,
                    actual:     act.age
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDepthLimitStopsRecursion()
    {
        struct Inner: Equatable
        {
            let value: Int
        }
        
        struct Outer: Equatable
        {
            let inner: Inner
        }
        
        let exp     = Outer(inner: Inner(value: 1))
        let act     = Outer(inner: Inner(value: 2))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    DiffOptions(maxRecursionDepth: 1)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "inner"),
                    expected:   exp.inner,
                    actual:     act.inner
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUnlimitedDepth()
    {
        struct L4: Equatable { let value    : Int }
        struct L3: Equatable { let l4       : L4 }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        let exp     = L1(l2: L2(l3: L3(l4: L4(value: 1))))
        let act     = L1(l2: L2(l3: L3(l4: L4(value: 2))))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
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
                                        .makeLeaf(
                                            label:      .property(
                                                            name: "value"
                                                        ),
                                            expected:   exp.l2.l3.l4.value,
                                            actual:     act.l2.l3.l4.value
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDepthLimitAtExactBoundary()
    {
        struct L5: Equatable { let value    : Int }
        struct L4: Equatable { let l5       : L5 }
        struct L3: Equatable { let l4       : L4 }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        let exp     = L1(l2: L2(l3: L3(l4: L4(l5: L5(value: 1)))))
        let act     = L1(l2: L2(l3: L3(l4: L4(l5: L5(value: 2)))))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    DiffOptions(maxRecursionDepth: 3)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
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
                                .makeLeaf(
                                    label:      .property(name: "l4"),
                                    expected:   exp.l2.l3.l4,
                                    actual:     act.l2.l3.l4
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDeeplyNestedEqualStructs()
    {
        struct L4: Equatable { let value    : Int }
        struct L3: Equatable { let l4       : L4 }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        let exp = L1(l2: L2(l3: L3(l4: L4(value: 99))))
        
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
    
    
    
    func testDeeplyNestedStructsWithMultipleEqualSiblings()
    {
        struct Leaf: Equatable
        {
            let value: Int
        }
        
        struct Parent: Equatable
        {
            let a   : Leaf
            let b   : Leaf
            let c   : Leaf
        }
        
        let exp = Parent(
            a:  Leaf(value: 1),
            b:  Leaf(value: 2),
            c:  Leaf(value: 3)
        )
        
        let act = Parent(
            a:  Leaf(value: 1),
            b:  Leaf(value: 0),
            c:  Leaf(value: 3)
        )
        
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
                    label:      .property(name: "b"),
                    expected:   exp.b,
                    actual:     act.b,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "value"),
                            expected:   exp.b.value,
                            actual:     act.b.value
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEmptyStructEqualValues()
    {
        struct Empty: Equatable { }
        
        let exp = Empty()
        
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
    
    
    
    func testEmptyStructWithPrivateBackingProperty()
    {
        struct Wrapper: Equatable
        {
            private var _value: Int
            
            var value: Int
            {
                return _value
            }
            
            init(
                value: Int
            )
            {
                self._value = value
            }
        }
        
        let exp     = Wrapper(value: 10)
        let act     = Wrapper(value: 20)
        
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
                    label:      .property(name: "_value"),
                    expected:   exp.value,
                    actual:     act.value
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
