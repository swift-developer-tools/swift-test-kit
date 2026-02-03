//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore
@testable import TKTestSupport



internal final class ComparatorOptionalTests: XCTestCase
{
    func testOptionalBothNone() throws
    {
        let exp: String? = nil
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOptionalBothSomeDifferent() throws
    {
        let exp : String?   = "hello"
        let act : String?   = "world"
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "some"),
                    expected:   exp,
                    actual:     act,
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 4),
                            expected:   "hell",
                            actual:     "w"
                        ),
                        
                        .makeUnexpected(
                            label:      .character(index: 5, count: 3),
                            actual:     "rld"
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOptionalBothSomeEqual() throws
    {
        let exp: String? = "hello"
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOptionalExpectedNoneActualSome() throws
    {
        let exp : String?   = nil
        let act : String?   = "hello"
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .property(name: "some"),
                    actual:     act!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOptionalExpectedSomeActualNone() throws
    {
        let exp : String?   = "hello"
        let act : String?   = nil
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .property(name: "some"),
                    expected:   exp!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOptionalBothSomeDifferentWrappedValue() throws
    {
        let exp : Int???    = 1
        let act : Int???    = 2
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "some"),
                    expected:   exp! as Int??,
                    actual:     act! as Int??,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   exp!! as Int?,
                            actual:     act!! as Int?,
                            tree:
                            [
                                .makeLeaf(
                                    label:      .property(name: "some"),
                                    expected:   exp!!!,
                                    actual:     act!!!
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOptionalNilAtDifferentLevels() throws
    {
        let exp : Int???    = .some(.some(nil))
        let act : Int???    = .some(nil)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "some"),
                    expected:   exp! as Int??,
                    actual:     act! as Int??,
                    tree:
                    [
                        .makeMissing(
                            label:      .property(name: "some"),
                            expected:   exp!! as Int?
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOptionalBothNilAtSameLevel() throws
    {
        let exp: Int??? = .some(.some(nil))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOptionalSomeVsOutermostNil() throws
    {
        let exp : Int???    = 1
        let act : Int???    = nil
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .property(name: "some"),
                    expected:   exp! as Int??
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOptionalBothOutermostNil() throws
    {
        let exp: Int??? = nil
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
}
