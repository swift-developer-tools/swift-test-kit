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



final class DiffEngineTests: XCTestKitCase
{
    // MARK: - Arrays
    
    func testArrayHashableMissingElement() throws
    {
        let expected    : [String]  = ["a", "b", "c"]
        let actual      : [String]  = ["a", "b"]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
            XCTFail("Expected .missingElement at index 2")
            return
        }
        
        XCTAssertEqual(exp as? String, "c")
    }
    
    
    
    func testArrayHashableModifiedElement() throws
    {
        let expected    : [String]  = ["a", "b", "c"]
        let actual      : [String]  = ["a", "x", "c"]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
            XCTFail("Expected .different at index 1")
            return
        }
        
        XCTAssertEqual(exp as? String, "b")
        XCTAssertEqual(act as? String, "x")
        XCTAssertTrue(childTree.isEmpty)
    }
    
    
    
    func testArrayHashableUnexpectedElement() throws
    {
        let expected    : [String]  = ["a", "b"]
        let actual      : [String]  = ["a", "b", "c"]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
            XCTFail("Expected .unexpectedElement at index 2")
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
        
        let node: DiffNode = DiffEngine.computeDiff(
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
            XCTFail("Expected .different at index 1")
            return
        }
        
        XCTAssertEqual(childTree.count, 1)
        XCTAssertEqual(childTree[0].label, .property(name: "id"))
    }
    
    
    
    // MARK: - Depth
    
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
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    options
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "inner"))
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different for property 'inner'")
            return
        }
        
        XCTAssertEqual((exp as? Inner)?.value, 1)
        XCTAssertEqual((act as? Inner)?.value, 2)
        XCTAssertTrue(childTree.isEmpty)
    }
    
    
    
    func testUnlimitedDepth() throws
    {
        struct L3: Equatable { let value    : Int }
        struct L2: Equatable { let l3       : L3 }
        struct L1: Equatable { let l2       : L2 }
        
        let expected    = L1(l2: L2(l3: L3(value: 1)))
        let actual      = L1(l2: L2(l3: L3(value: 2)))
        let options     = XCTKDiffOptions(maxRecursionDepth: nil)
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    options
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different at root, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different at level 2, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different at level 3, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "value"))
    }
    
    
    
    // MARK: - Dictionaries
    
    func testDictionaryDifferentValue() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2]
        let actual      : [String : Int]    = ["a": 1, "b": 0]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different for key 'b'")
            return
        }
        
        XCTAssertEqual(exp as? Int, 2)
        XCTAssertEqual(act as? Int, 0)
        XCTAssertTrue(childTree.isEmpty)
    }
    
    
    
    func testDictionaryMissingEntry() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2]
        let actual      : [String : Int]    = ["a": 1]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement for key 'b'")
            return
        }
        
        XCTAssertEqual(exp as? Int, 2)
    }
    
    
    
    func testDictionaryUnexpectedEntry() throws
    {
        let expected    : [String : Int]    = ["a": 1]
        let actual      : [String : Int]    = ["a": 1, "b": 2]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement for key 'b'")
            return
        }
        
        XCTAssertEqual(act as? Int, 2)
    }
    
    
    
    // MARK: - Optionals
    
    func testOptionalBothNone() throws
    {
        let expected    : String?   = nil
        let actual      : String?   = nil
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testOptionalBothSomeDifferent() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = "world"
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        XCTAssertEqual(tree[0].label, .property(name: "some"))
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different for wrapped value")
            return
        }
        
        XCTAssertEqual(exp as? String, "hello")
        XCTAssertEqual(act as? String, "world")
        XCTAssertTrue(childTree.isEmpty)
    }
    
    
    
    func testOptionalBothSomeEqual() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = "hello"
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testOptionalExpectedNoneActualSome() throws
    {
        let expected    : String?   = nil
        let actual      : String?   = "hello"
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        XCTAssertEqual(tree[0].label, .property(name: "some"))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement for wrapped value")
            return
        }
        
        XCTAssertEqual(act as? String, "hello")
    }
    
    
    
    func testOptionalExpectedSomeActualNone() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = nil
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        XCTAssertEqual(tree[0].label, .property(name: "some"))
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement for wrapped value")
            return
        }
        
        XCTAssertEqual(exp as? String, "hello")
    }
    
    
    
    // MARK: - Primitives
    
    func testPrimitiveEqualValues() throws
    {
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   10,
            actual:     10
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(expected) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(expected as? Int, 10)
    }
    
    
    
    // MARK: - Sets
    
    func testSetMissingEntry() throws
    {
        let expected    : Set<String>   = ["a", "b", "c"]
        let actual      : Set<String>   = ["a", "b"]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        XCTAssertEqual(tree[0].label, .member)
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement")
            return
        }
        
        XCTAssertEqual(exp as? String, "c")
    }
    
    
    
    func testSetUnexpectedEntry() throws
    {
        let expected    : Set<String>   = ["a", "b"]
        let actual      : Set<String>   = ["a", "b", "c"]
        
        let node: DiffNode = DiffEngine.computeDiff(
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
        XCTAssertEqual(tree[0].label, .member)
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement")
            return
        }
        
        XCTAssertEqual(act as? String, "c")
    }
    
    
    
    // MARK: - Structs
    
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
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, personTree) = node.kind
        else
        {
            XCTFail("Expected .different at root")
            return
        }
        
        XCTAssertEqual(personTree.count, 1)
        XCTAssertEqual(personTree[0].label, .property(name: "address"))
        
        
        
        guard case let .different(_, _, addressTree) = personTree[0].kind
        else
        {
            XCTFail("Expected .different for property 'address'")
            return
        }
        
        XCTAssertEqual(addressTree.count, 1)
        XCTAssertEqual(addressTree[0].label, .property(name: "zip"))
        
        
        
        guard case let .different(exp, act, addressChildTree)
            = addressTree[0].kind
        else
        {
            XCTFail("Expected .different for property 'zip'")
            return
        }
        
        XCTAssertEqual(exp as? String, "12345")
        XCTAssertEqual(act as? String, "54321")
        XCTAssertTrue(addressChildTree.isEmpty)
    }
    
    
    
    func testStructEqualValues() throws
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        
        
        let user = User(
            name:   "Someone",
            age:    10
        )
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   user,
            actual:     user
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
        
        let node: DiffNode = DiffEngine.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "age"))
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different for age node kind")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
        XCTAssertEqual(act as? Int, 20)
        XCTAssertTrue(childTree.isEmpty)
    }
}
