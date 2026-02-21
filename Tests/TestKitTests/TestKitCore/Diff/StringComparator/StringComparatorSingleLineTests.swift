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



internal final class StringComparatorSingleLineTests: TestKitCase
{
    func testSingleLineEqualStrings()
    {
        let exp: String = "hello"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     exp
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleLineDifferentStrings()
    {
        let exp : String    = "hello"
        let act : String    = "hallo"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 1, count: 1),
                    expected:   "e",
                    actual:     "a"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEmptyStringsEqual()
    {
        let exp: String = ""
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     exp
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEmptyVsNonEmpty()
    {
        let exp : String    = ""
        let act : String    = "hello"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeUnexpected(
                    label:      .character(index: 0, count: 5),
                    actual:     "hello"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNonEmptyVsEmpty()
    {
        let exp : String    = "hello"
        let act : String    = ""
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeMissing(
                    label:      .character(index: 0, count: 5),
                    expected:   "hello"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharChangeAtStringStart()
    {
        let exp : String    = "hello"
        let act : String    = "Xello"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 0, count: 1),
                    expected:   "h",
                    actual:     "X"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCharChangeAtStringEnd()
    {
        let exp : String    = "hello"
        let act : String    = "hellX"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 4, count: 1),
                    expected:   "o",
                    actual:     "X"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPrefixMatch()
    {
        let exp : String    = "abc"
        let act : String    = "abcdef"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeUnexpected(
                    label:      .character(index: 3, count: 3),
                    actual:     "def"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSuffixMatch()
    {
        let exp : String    = "abcdef"
        let act : String    = "def"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeMissing(
                    label:      .character(index: 0, count: 3),
                    expected:   "abc"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleCharStrings()
    {
        let exp : String    = "a"
        let act : String    = "b"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 0, count: 1),
                    expected:   "a",
                    actual:     "b"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testWhitespaceOnlyDifference()
    {
        let exp : String    = "hello world"
        let act : String    = "hello  world"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeUnexpected(
                    label:      .character(index: 6, count: 1),
                    actual:     " "
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTabVsSpace()
    {
        let exp : String    = "hello\tworld"
        let act : String    = "hello world"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 5, count: 1),
                    expected:   "\t",
                    actual:     " "
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
