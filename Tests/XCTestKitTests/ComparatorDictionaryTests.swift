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
        
        XCTAssertEqual(exp as? Int, 2)
        XCTAssertEqual(act as? Int, 0)
        XCTAssertTrue(tree2.isEmpty)
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
}
