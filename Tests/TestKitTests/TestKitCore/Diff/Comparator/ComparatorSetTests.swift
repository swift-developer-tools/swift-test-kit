//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitCore



internal final class ComparatorSetTests: TestKitCase
{
    func testSetEqualValues()
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
    
    
    
    func testSetMissingEntry()
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
    
    
    
    func testSetMultipleMissingEntries()
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
    
    
    
    func testSetUnexpectedEntry()
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
    
    
    
    func testSetMultipleUnexpectedEntries()
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
    
    
    
    func testSetMixedChanges()
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
    
    
    
    func testSetEmptyVsNonEmpty()
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
    
    
    
    func testSetNonEmptyVsEmpty()
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
    
    
    
    func testSetBothEmpty()
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
    
    
    
    func testSetOfOptionals()
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
