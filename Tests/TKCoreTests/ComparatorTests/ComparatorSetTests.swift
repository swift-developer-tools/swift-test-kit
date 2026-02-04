//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TKTestSupport
import XCTest



internal final class ComparatorSetTests: XCTestCase
{
    func testSetEqualValues() throws
    {
        let exp: Set<String> = ["a", "b", "c"]
        
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
    
    
    
    func testSetMissingEntry() throws
    {
        let exp : Set<String>   = ["a", "b", "c"]
        let act : Set<String>   = ["a", "b"]
        
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
                    label:      .member,
                    expected:   "c"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetMultipleMissingEntries() throws
    {
        let exp : Set<String>   = ["a", "b", "c", "d"]
        let act : Set<String>   = ["a"]
        
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
                    label:      .member,
                    expected:   "b"
                ),
                
                .makeMissing(
                    label:      .member,
                    expected:   "c"
                ),
            
                .makeMissing(
                    label:      .member,
                    expected:   "d"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetUnexpectedEntry() throws
    {
        let exp : Set<String>   = ["a", "b"]
        let act : Set<String>   = ["a", "b", "c"]
        
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
                    label:      .member,
                    actual:     "c"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetMultipleUnexpectedEntries() throws
    {
        let exp : Set<String>   = ["a"]
        let act : Set<String>   = ["a", "b", "c", "d"]
        
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
                    label:      .member,
                    actual:     "b"
                ),
                
                .makeUnexpected(
                    label:      .member,
                    actual:     "c"
                ),
            
                .makeUnexpected(
                    label:      .member,
                    actual:     "d"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetMixedChanges() throws
    {
        let exp : Set<String>   = ["a", "b", "c"]
        let act : Set<String>   = ["a", "d", "e"]
        
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
                    label:      .member,
                    expected:   "b"
                ),
                
                .makeMissing(
                    label:      .member,
                    expected:   "c"
                ),
                
                .makeUnexpected(
                    label:      .member,
                    actual:     "d"
                ),
            
                .makeUnexpected(
                    label:      .member,
                    actual:     "e"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetEmptyVsNonEmpty() throws
    {
        let exp : Set<String>   = []
        let act : Set<String>   = ["a", "b"]
        
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
                    label:      .member,
                    actual:     "a"
                ),
            
                .makeUnexpected(
                    label:      .member,
                    actual:     "b"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetNonEmptyVsEmpty() throws
    {
        let exp : Set<String>   = ["a", "b"]
        let act : Set<String>   = []
        
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
                    label:      .member,
                    expected:   "a"
                ),
                
                .makeMissing(
                    label:      .member,
                    expected:   "b"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetBothEmpty() throws
    {
        let exp: Set<String> = []
        
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
    
    
    
    func testSetOfOptionals() throws
    {
        let exp : Set<Int?>     = [1, nil, 3]
        let act : Set<Int?>     = [1, 2, 3]
        
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
                    label:      .member,
                    actual:     Optional<Int>(2)
                ),
                
                .makeMissing(
                    label:      .member,
                    expected:   Optional<Int>(nil)
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
