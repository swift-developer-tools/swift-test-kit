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
}
