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
        
        let exp = Container(pair: (1, "hello"))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
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
        
        let exp     = Container(pair: (1, "hello"))
        let act     = Container(pair: (1, "goodbye"))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructuralAny(
                    label:      .property(name: "pair"),
                    expected:   exp.pair,
                    actual:     act.pair,
                    tree:
                    [
                        .makeStructuralAny(
                            label:      .property(name: ".1"),
                            expected:   exp.pair.1,
                            actual:     act.pair.1,
                            tree:
                            [
                                .makeLeaf(
                                    label:      .character(index: 0, count: 4),
                                    expected:   "hell",
                                    actual:     "g"
                                ),
                                
                                .makeUnexpected(
                                    label:      .character(index: 5, count: 5),
                                    actual:     "odbye"
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
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
        
        let exp     = Container(user: (name: "Someone", age: 30))
        let act     = Container(user: (name: "Someone", age: 20))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructuralAny(
                    label:      .property(name: "user"),
                    expected:   exp.user,
                    actual:     act.user,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "age"),
                            expected:   exp.user.age,
                            actual:     act.user.age,
                        )
                    ]
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
}
