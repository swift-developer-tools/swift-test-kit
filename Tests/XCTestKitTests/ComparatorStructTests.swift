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



final class ComparatorStructTests: XCTestKitCase
{
    func testNestedStructs() throws
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
        
        
        
        let expected = Person(
            name:       "Someone",
            address:    Address(city: "Place", zip: "12345")
        )
        
        let actual = Person(
            name:       "Someone",
            address:    Address(city: "Place", zip: "54321")
        )
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "address"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "zip"))
        
        
        
        guard case let .different(exp, act, tree3)
                = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "12345")
        XCTAssertEqual(act as? String, "54321")
        XCTAssertFalse(tree3.isEmpty)
        XCTAssertEqual(tree3[0].label, .character(0))
        XCTAssertEqual(tree3[1].label, .character(5))
    }
    
    
    
    func testStructEqualValues() throws
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        
        
        let expected = User(
            name:   "Someone",
            age:    10
        )
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testStructSinglePropertyDifference() throws
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        
        
        let expected = User(
            name:   "Someone",
            age:    10
        )
        
        let actual = User(
            name:   "Someone",
            age:    20
        )
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "age"))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
        XCTAssertEqual(act as? Int, 20)
        XCTAssertTrue(tree2.isEmpty)
    }
    
    
    
    func testDepthLimitStopsRecursion() throws
    {
        struct Inner: Equatable
        {
            let value: Int
        }
        
        struct Outer: Equatable
        {
            let inner: Inner
        }
        
        
        
        let expected    = Outer(inner: Inner(value: 1))
        let actual      = Outer(inner: Inner(value: 2))
        
        /// Examine the children of `Outer`, but not those of `Inner`.
        let options = XCTKDiffOptions(maxRecursionDepth: 1)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    options
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "inner"))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual((exp as? Inner)?.value, 1)
        XCTAssertEqual((act as? Inner)?.value, 2)
        XCTAssertTrue(tree2.isEmpty)
    }
    
    
    
    func testUnlimitedDepth() throws
    {
        struct L4: Equatable { let value    : Int }
        struct L3: Equatable { let l4       : L4 }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        
        
        let expected    = L1(l2: L2(l3: L3(l4: L4(value: 1))))
        let actual      = L1(l2: L2(l3: L3(l4: L4(value: 2))))
        let options     = XCTKDiffOptions(maxRecursionDepth: nil)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    options
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "l2"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "l3"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "l4"))
        
        
        
        guard case let .different(_, _, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(tree4.count, 1)
        XCTAssertEqual(tree4[0].label, .property(name: "value"))
        
        
        
        guard case let .different(exp, act, tree5) = tree4[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree4[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 1)
        XCTAssertEqual(act as? Int, 2)
        XCTAssertTrue(tree5.isEmpty)
    }
    
    
    
    func testDeeplyNestedEqualStructs() throws
    {
        struct L4: Equatable { let value    : Int }
        struct L3: Equatable { let l4       : L4 }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        
        
        let expected = L1(l2: L2(l3: L3(l4: L4(value: 99))))
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testDeeplyNestedStructsWithMultipleEqualSiblings() throws
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
        
        
        
        let expected = Parent(
            a:  Leaf(value: 1),
            b:  Leaf(value: 2),
            c:  Leaf(value: 3)
        )
        
        let actual = Parent(
            a:  Leaf(value: 1),
            b:  Leaf(value: 0),
            c:  Leaf(value: 3)
        )
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "b"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "value"))
    }
    
    
    
    func testEmptyStructEqualValues() throws
    {
        struct Empty: Equatable { }
        
        let expected = Empty()
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testEmptyStructWithPrivateBackingProperty() throws
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
        
        
        
        let expected    = Wrapper(value: 10)
        let actual      = Wrapper(value: 20)
        
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
        XCTAssertEqual(tree[0].label, .property(name: "_value"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
        XCTAssertEqual(act as? Int, 20)
    }
    
    
    
    func testDepthLimitAtExactBoundary() throws
    {
        struct L5: Equatable { let value    : Int }
        struct L4: Equatable { let l5       : L5 }
        struct L3: Equatable { let l4       : L4 }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        
        
        let expected    = L1(l2: L2(l3: L3(l4: L4(l5: L5(value: 1)))))
        let actual      = L1(l2: L2(l3: L3(l4: L4(l5: L5(value: 2)))))
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(maxRecursionDepth: 3)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "l2"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "l3"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "l4"))
        
        
        
        guard case let .different(exp, act, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        /// Depth limit reached. Leaf comparison with an empty tree.
        XCTAssertTrue(exp is L4)
        XCTAssertTrue(act is L4)
        XCTAssertTrue(tree4.isEmpty)
    }
}
