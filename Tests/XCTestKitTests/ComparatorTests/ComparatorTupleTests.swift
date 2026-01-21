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



final class ComparatorTupleTests: XCTestKitCase
{
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
        
        guard node.kind.isSame
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
        
        XCTAssertEqual(exp.value as? String, "hello")
        XCTAssertEqual(act.value as? String, "goodbye")
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
        
        XCTAssertEqual(exp.value as? Int, 30)
        XCTAssertEqual(act.value as? Int, 20)
        XCTAssertTrue(tree3.isEmpty)
    }
}
