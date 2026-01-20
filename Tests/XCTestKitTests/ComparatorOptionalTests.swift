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



final class ComparatorOptionalTests: XCTestKitCase
{
    func testOptionalBothNone() throws
    {
        let expected: String? = nil
        
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
    
    
    
    func testOptionalBothSomeDifferent() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = "world"
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "some"))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "hello")
        XCTAssertEqual(act.value as? String, "world")
        XCTAssertEqual(tree2.count, 2)
        XCTAssertEqual(tree2[0].label, .character(0))
        XCTAssertEqual(tree2[1].label, .character(5))
    }
    
    
    
    func testOptionalBothSomeEqual() throws
    {
        let expected    : String?   = "hello"
        let actual      : String?   = "hello"
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard node.kind.isSame
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
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "hello")
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
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "hello")
    }
    
    
    
    func testNestedOptionalBothSomeDifferentWrappedValue() throws
    {
        let expected    : Int???    = 1
        let actual      : Int???    = 2
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "some"))
        
        
        
        guard case let .different(exp, act, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 1)
        XCTAssertEqual(act.value as? Int, 2)
        XCTAssertTrue(tree4.isEmpty)
    }
    
    
    
    func testNestedOptionalNilAtDifferentLevels() throws
    {
        let expected    : Int???    = .some(.some(nil))
        let actual      : Int???    = .some(nil)
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .missing(exp) = tree2[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertTrue(exp.value is Int?)
    }
    
    
    
    func testNestedOptionalBothNilAtSameLevel() throws
    {
        let expected: Int??? = .some(.some(nil))
        
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
    
    
    
    func testNestedOptionalSomeVsOutermostNil() throws
    {
        let expected    : Int???    = 1
        let actual      : Int???    = nil
        
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
        XCTAssertEqual(tree1[0].label, .property(name: "some"))
        
        
        
        guard case let .missing(exp) = tree1[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertTrue(exp.value is Int??)
    }
    
    
    
    func testNestedOptionalBothOutermostNil() throws
    {
        let expected: Int??? = nil
        
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
}
