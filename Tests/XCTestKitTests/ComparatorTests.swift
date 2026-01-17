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



final class ComparatorTests: XCTestKitCase
{
    // MARK: - Arrays
    
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
    
    
    
    // MARK: - Dictionaries
    
    func testDictionaryDifferentValue() throws
    {
        let expected    : [String : Int]    = ["a": 1, "b": 2]
        let actual      : [String : Int]    = ["a": 1, "b": 0]
        
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
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
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
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 2)
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
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act as? Int, 2)
    }
    
    
    
    // MARK: - Enums
    
    func testEnumDifferentCases() throws
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String, code: Int)
        }
        
        
        
        let expected    : Status    = .success(data: "hello")
        let actual      : Status    = .failure(error: "goodbye", code: 418)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Status, expected)
        XCTAssertEqual(act as? Status, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumSameCaseSameValues() throws
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        
        
        let expected: Status = .success(data: "hello")
        
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
    
    
    
    func testEnumSameCaseDifferentValues() throws
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        
        
        let expected    : Status    = .success(data: "hello")
        let actual      : Status    = .success(data: "goodbye")
        
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
        XCTAssertEqual(tree[0].label, .property(name: "data"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "hello")
        XCTAssertEqual(act as? String, "goodbye")
    }
    
    
    
    func testEnumWithoutAssocDifferentCases() throws
    {
        enum State: Equatable
        {
            case loading
            case ready
            case error
        }
        
        
        
        let expected    : State     = .loading
        let actual      : State     = .error
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? State, expected)
        XCTAssertEqual(act as? State, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumWithoutAssocSameCase() throws
    {
        enum State: Equatable
        {
            case loading
            case ready
        }
        
        
        
        let expected: State = .loading
        
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
    
    
    
    func testEnumMixedCaseWithAssocVsWithout() throws
    {
        enum State: Equatable
        {
            case loading
            case loaded(data: String)
        }
        
        
        
        let expected    : State     = .loaded(data: "hello")
        let actual      : State     = .loading
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? State, expected)
        XCTAssertEqual(act as? State, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumMixedCaseWithoutAssocVsWith() throws
    {
        enum State: Equatable
        {
            case loading
            case loaded(data: String)
        }
        
        
        
        let expected    : State     = .loading
        let actual      : State     = .loaded(data: "hello")
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? State, expected)
        XCTAssertEqual(act as? State, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumMultipleAssocSomeDifferent() throws
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        
        
        let expected    : Result    = .success(a: 1, b: "x", c: 2)
        let actual      : Result    = .success(a: 1, b: "y", c: 2)
        
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
        XCTAssertEqual(tree[0].label, .property(name: "b"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "x")
        XCTAssertEqual(act as? String, "y")
    }
    
    
    
    func testEnumMultipleAssocAllDifferent() throws
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        
        
        let expected    : Result    = .success(a: 1, b: "x", c: 2)
        let actual      : Result    = .success(a: 3, b: "y", c: 4)
        
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
        XCTAssertEqual(tree[0].label, .property(name: "a"))
        XCTAssertEqual(tree[1].label, .property(name: "b"))
        XCTAssertEqual(tree[2].label, .property(name: "c"))
    }
    
    
    
    func testEnumUnlabeledAssoc() throws
    {
        enum Wrapper: Equatable
        {
            case pair(Int, Int)
        }
        
        
        
        let expected    : Wrapper    = .pair(1, 2)
        let actual      : Wrapper    = .pair(1, 4)
        
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
        XCTAssertEqual(tree[0].label, .property(name: ".1"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 2)
        XCTAssertEqual(act as? Int, 4)
    }
    
    
    
    func testEnumSingleUnlabeledAssoc() throws
    {
        enum Wrapper: Equatable
        {
            case value(Int)
        }
        
        
        
        let expected    : Wrapper    = .value(1)
        let actual      : Wrapper    = .value(2)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp1 as? Wrapper, expected)
        XCTAssertEqual(act1 as? Wrapper, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(0))
        
        
        
        guard case let .different(exp2, act2, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp2 as? Int, 1)
        XCTAssertEqual(act2 as? Int, 2)
    }
    
    
    
    func testEnumRawValueDifferentCases() throws
    {
        enum Priority: Int, Equatable
        {
            case low        = 1
            case medium     = 2
            case high       = 3
        }
        
        
        
        let expected    : Priority  = .low
        let actual      : Priority  = .high
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Priority, expected)
        XCTAssertEqual(act as? Priority, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumRawValueSameCase() throws
    {
        enum Priority: Int, Equatable
        {
            case low        = 1
            case medium     = 2
            case high       = 3
        }
        
        
        
        let expected: Priority = .low
        
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
    
    
    
    // MARK: - Optionals
    
    func testOptionalBothNone() throws
    {
        let expected    : String?   = nil
        let actual      : String?   = nil
        
        let node: DiffNode = Comparator.computeDiff(
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
        XCTAssertEqual(tree[0].label, .property(name: "some"))
        
        
        
        guard case let .different(exp, act, childTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "hello")
        XCTAssertEqual(act as? String, "world")
        XCTAssertEqual(childTree.count, 2)
        XCTAssertEqual(childTree[0].label, .character(0))
        XCTAssertEqual(childTree[1].label, .character(5))
    }
    
    
    
    func testOptionalBothSomeEqual() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = "hello"
        
        let node: DiffNode = Comparator.computeDiff(
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
        XCTAssertEqual(tree[0].label, .property(name: "some"))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act as? String, "hello")
    }
    
    
    
    func testOptionalExpectedSomeActualNone() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = nil
        
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
        XCTAssertEqual(tree[0].label, .property(name: "some"))
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "hello")
    }
    
    
    
    // MARK: - Primitives
    
    func testPrimitiveEqualValues() throws
    {
        let node: DiffNode = Comparator.computeDiff(
            expected:   10,
            actual:     10
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
    }
    
    
    
    // MARK: - Sets
    
    func testSetMissingEntry() throws
    {
        let expected    : Set<String>   = ["a", "b", "c"]
        let actual      : Set<String>   = ["a", "b"]
        
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
        XCTAssertEqual(tree[0].label, .member)
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "c")
    }
    
    
    
    func testSetUnexpectedEntry() throws
    {
        let expected    : Set<String>   = ["a", "b"]
        let actual      : Set<String>   = ["a", "b", "c"]
        
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
        XCTAssertEqual(tree[0].label, .member)
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
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
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, personTree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(personTree.count, 1)
        XCTAssertEqual(personTree[0].label, .property(name: "address"))
        
        
        
        guard case let .different(_, _, addressTree) = personTree[0].kind
        else
        {
            XCTFail("Expected .different, got \(personTree[0].kind)")
            return
        }
        
        XCTAssertEqual(addressTree.count, 1)
        XCTAssertEqual(addressTree[0].label, .property(name: "zip"))
        
        
        
        guard case let .different(exp, act, addressChildTree)
            = addressTree[0].kind
        else
        {
            XCTFail("Expected .different, got \(addressTree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "12345")
        XCTAssertEqual(act as? String, "54321")
        XCTAssertFalse(addressChildTree.isEmpty)
        XCTAssertEqual(addressChildTree[0].label, .character(0))
        XCTAssertEqual(addressChildTree[1].label, .character(5))
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
        
        let node: DiffNode = Comparator.computeDiff(
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
        
        let node: DiffNode = Comparator.computeDiff(
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
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
        XCTAssertEqual(act as? Int, 20)
        XCTAssertTrue(childTree.isEmpty)
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
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual((exp as? Inner)?.value, 1)
        XCTAssertEqual((act as? Inner)?.value, 2)
        XCTAssertTrue(childTree.isEmpty)
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
        
        
        
        guard case let .different(exp, act, valueTree) = tree4[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree4[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 1)
        XCTAssertEqual(act as? Int, 2)
        XCTAssertTrue(valueTree.isEmpty)
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
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "b"))
        
        
        
        guard case let .different(_, _, valueTree) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(valueTree.count, 1)
        XCTAssertEqual(valueTree[0].label, .property(name: "value"))
    }
    
    
    
    // MARK: - Tuples
    
    func testNestedTupleEqualValues() throws
    {
        struct Container: Equatable
        {
            let pair: (Int, String)
            
            static func == (
                lhs : Container,
                rhs : Container
            ) -> Bool
            {
                lhs.pair == rhs.pair
            }
        }
        
        
        
        let expected = Container(pair: (1, "hello"))
        
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
    
    
    
    func testNestedTupleSingleElementDifference() throws
    {
        struct Container: Equatable
        {
            let pair: (Int, String)
            
            static func == (
                lhs : Container,
                rhs : Container
            ) -> Bool
            {
                lhs.pair == rhs.pair
            }
        }
        
        
        
        let expected    = Container(pair: (1, "hello"))
        let actual      = Container(pair: (1, "goodbye"))
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "pair"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: ".1"))
        
        
        
        guard case let .different(exp, act, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "hello")
        XCTAssertEqual(act as? String, "goodbye")
        XCTAssertEqual(tree3.count, 2)
    }
    
    
    
    func testNestedLabeledTupleSingleElementDifference() throws
    {
        struct Container: Equatable
        {
            let user: (name: String, age: Int)
            
            static func == (
                lhs : Container,
                rhs : Container
            ) -> Bool
            {
                lhs.user == rhs.user
            }
        }
        
        
        
        let expected    = Container(user: (name: "Someone", age: 30))
        let actual      = Container(user: (name: "Someone", age: 20))
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "user"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "age"))
        
        
        
        guard case let .different(exp, act, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 30)
        XCTAssertEqual(act as? Int, 20)
        XCTAssertTrue(tree3.isEmpty)
    }
}
