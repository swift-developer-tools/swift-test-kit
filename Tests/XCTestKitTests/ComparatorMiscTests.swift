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



final class ComparatorMiscTests: XCTestKitCase
{
    func testBooleanEqualValues() throws
    {
        let expected: Bool = true
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testBooleanDifferentValues() throws
    {
        let expected    : Bool    = true
        let actual      : Bool    = false
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Bool, expected)
        XCTAssertEqual(act as? Bool, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testIntegerEqualValues() throws
    {
        let expected: Int = 10
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, expected)
    }
    
    
    
    func testIntegerDifferentValues() throws
    {
        let expected    : Int   = 10
        let actual      : Int   = 20
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, expected)
        XCTAssertEqual(act as? Int, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testFloatEqualValues() throws
    {
        let expected: Float64 = 10 / 3
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Float64, expected)
    }
    
    
    
    func testFloatDifferentValues() throws
    {
        let expected    : Float64   = 10 / 3
        let actual      : Float64   = 20 / 3
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Float64, expected)
        XCTAssertEqual(act as? Float64, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testStringEqualValues() throws
    {
        let expected: String = "hello"
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, expected)
    }
    
    
    
    func testStringDifferentValues() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "goodbye"
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, expected)
        XCTAssertEqual(act as? String, actual)
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .character(0))
        XCTAssertEqual(tree[1].label, .character(5))
    }
}
