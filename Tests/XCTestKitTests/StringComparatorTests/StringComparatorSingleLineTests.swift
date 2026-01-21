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



final class StringComparatorSingleLineTests: XCTestKitCase
{
    func testSingleLineEqualStrings() throws
    {
        let expected: String = "hello"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     expected
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testSingleLineDifferentStrings() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "hallo"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree1) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, expected)
        XCTAssertEqual(act1.value as? String, actual)
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .character(index: 1, count: 1))
        
        
        
        guard case let .different(exp2, act2, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "e")
        XCTAssertEqual(act2.value as? String, "a")
        XCTAssertTrue(tree2.isEmpty)
    }
    
    
    
    func testEmptyStringsEqual() throws
    {
        let expected: String = ""
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     expected
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testEmptyVsNonEmpty() throws
    {
        let expected    : String    = ""
        let actual      : String    = "hello"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, expected)
        XCTAssertEqual(act1.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 0, count: 5))
        
        
        
        guard case let .unexpected(act2) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, actual)
    }
    
    
    
    func testNonEmptyVsEmpty() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = ""
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, expected)
        XCTAssertEqual(act1.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 0, count: 5))
        
        
        
        guard case let .missing(exp2) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, expected)
    }
    
    
    
    func testCharChangeAtStringStart() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "Xello"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 0, count: 1))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "h")
        XCTAssertEqual(act.value as? String, "X")
    }
    
    
    
    func testCharChangeAtStringEnd() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "hellX"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 4, count: 1))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "o")
        XCTAssertEqual(act.value as? String, "X")
    }
    
    
    
    func testPrefixMatch() throws
    {
        let expected    : String    = "abc"
        let actual      : String    = "abcdef"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 3, count: 3))
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "def")
    }
    
    
    
    func testSuffixMatch() throws
    {
        let expected    : String    = "abcdef"
        let actual      : String    = "def"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 0, count: 3))
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "abc")
    }
    
    
    
    func testSingleCharStrings() throws
    {
        let expected    : String    = "a"
        let actual      : String    = "b"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, expected)
        XCTAssertEqual(act1.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 0, count: 1))
        
        
        
        guard case let .different(exp2, act2, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, expected)
        XCTAssertEqual(act2.value as? String, actual)
    }
    
    
    
    func testWhitespaceOnlyDifference() throws
    {
        let expected    : String    = "hello world"
        let actual      : String    = "hello  world"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 6, count: 1))
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, " ")
    }
    
    
    
    func testTabVsSpace() throws
    {
        let expected    : String    = "hello\tworld"
        let actual      : String    = "hello world"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(index: 5, count: 1))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "\t")
        XCTAssertEqual(act.value as? String, " ")
    }
}
