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



final class ComparatorSetTests: XCTestKitCase
{
    func testSetEqualValues() throws
    {
        let expected: Set<String> = ["a", "b", "c"]
        
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
        
        XCTAssertEqual(exp.value as? String, "c")
    }
    
    
    
    func testSetMultipleMissingEntries() throws
    {
        let expected    : Set<String>   = ["a", "b", "c", "d"]
        let actual      : Set<String>   = ["a"]
        
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
        XCTAssertEqual(tree[0].label, .member)
        XCTAssertEqual(tree[1].label, .member)
        XCTAssertEqual(tree[2].label, .member)
        
        
        
        guard case let .missingElement(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "b")
        
        
        
        guard case let .missingElement(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "c")
        
        
        
        guard case let .missingElement(exp3) = tree[2].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[2].kind)")
            return
        }
        
        XCTAssertEqual(exp3.value as? String, "d")
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
        
        XCTAssertEqual(act.value as? String, "c")
    }
    
    
    
    func testSetMultipleUnexpectedEntries() throws
    {
        let expected    : Set<String>   = ["a"]
        let actual      : Set<String>   = ["a", "b", "c", "d"]
        
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
        XCTAssertEqual(tree[0].label, .member)
        XCTAssertEqual(tree[1].label, .member)
        XCTAssertEqual(tree[2].label, .member)
        
        
        
        guard case let .unexpectedElement(act1) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act1.value as? String, "b")
        
        
        
        guard case let .unexpectedElement(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, "c")
        
        
        
        guard case let .unexpectedElement(act3) = tree[2].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[2].kind)")
            return
        }
        
        XCTAssertEqual(act3.value as? String, "d")
    }
    
    
    
    func testSetMixedChanges() throws
    {
        let expected    : Set<String>   = ["a", "b", "c"]
        let actual      : Set<String>   = ["a", "d", "e"]
        
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
        
        XCTAssertEqual(tree.count, 4)
        XCTAssertEqual(tree[0].label, .member)
        XCTAssertEqual(tree[1].label, .member)
        XCTAssertEqual(tree[2].label, .member)
        XCTAssertEqual(tree[3].label, .member)
        
        
        
        guard case let .missingElement(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "b")
        
        
        
        guard case let .missingElement(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "c")
        
        
        
        guard case let .unexpectedElement(act1) = tree[2].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[2].kind)")
            return
        }
        
        XCTAssertEqual(act1.value as? String, "d")
        
        
        
        guard case let .unexpectedElement(act2) = tree[3].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[3].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, "e")
    }
    
    
    
    func testSetEmptyVsNonEmpty() throws
    {
        let expected    : Set<String>   = []
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
        
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .member)
        XCTAssertEqual(tree[1].label, .member)
        
        
        
        guard case let .unexpectedElement(act1) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act1.value as? String, "a")
        
        
        
        guard case let .unexpectedElement(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, "b")
    }
    
    
    
    func testSetNonEmptyVsEmpty() throws
    {
        let expected    : Set<String>   = ["a", "b"]
        let actual      : Set<String>   = []
        
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
        XCTAssertEqual(tree[0].label, .member)
        XCTAssertEqual(tree[1].label, .member)
        
        
        
        guard case let .missingElement(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "a")
        
        
        
        guard case let .missingElement(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "b")
    }
    
    
    
    func testSetBothEmpty() throws
    {
        let expected: Set<String> = []
        
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
    
    
    
    func testSetOfOptionals() throws
    {
        let expected    : Set<Int?>     = [1, nil, 3]
        let actual      : Set<Int?>     = [1, 2, 3]
        
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
        XCTAssertEqual(tree[0].label, .member)
        XCTAssertEqual(tree[1].label, .member)
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? Int, 2)
        
        
        
        guard case let .missingElement(exp) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertTrue(exp.value is Int?)
        XCTAssertNil(exp.value as? Int)
    }
}
