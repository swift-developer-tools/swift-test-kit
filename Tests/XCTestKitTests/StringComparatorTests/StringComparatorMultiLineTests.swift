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



final class StringComparatorMultiLineTests: XCTestKitCase
{
    func testMultiLineEqualStrings() throws
    {
        let expected: String = "line0\nline1\nline2"
        
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
    
    
    
    func testMultiLineModifiedLine() throws
    {
        let expected    : String    = "line0\nline1\nline2"
        let actual      : String    = "line0\nlineX\nline2"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree1) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .line(1))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "line1")
        XCTAssertEqual(act.value as? String, "lineX")
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .character(index: 4, count: 1))
    }
    
    
    
    func testMultiLineMissingLine() throws
    {
        let expected    : String    = "line0\nline1\nline2"
        let actual      : String    = "line0\nline2"
        
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
        XCTAssertEqual(tree[0].label, .line(1))
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "line1")
    }
    
    
    
    func testMultiLineUnexpectedLine() throws
    {
        let expected    : String    = "line0\nline2"
        let actual      : String    = "line0\nline1\nline2"
        
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
        XCTAssertEqual(tree[0].label, .line(1))
        
        
        
        guard case let .unexpected(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "line1")
    }
    
    
    
    func testSingleLineVsMultiLine() throws
    {
        let expected    : String    = "single"
        let actual      : String    = "multiple\nlines"
        
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
        
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .line(0))
        XCTAssertEqual(tree[1].label, .line(1))
        
        
        
        guard case let .different(exp1, act1, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, expected)
        XCTAssertEqual(act1.value as? String, "multiple")
        
        
        
        guard case let .unexpected(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, "lines")
    }
    
    
    
    func testMultipleLineChanges() throws
    {
        let expected    : String    = "keep\nremove\nmodify"
        let actual      : String    = "keep\nchange\nadd"
        
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
        
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .line(1))
        XCTAssertEqual(tree[1].label, .line(2))
        
        
        
        guard case let .different(exp1, act1, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "remove")
        XCTAssertEqual(act1.value as? String, "change")
        
        
        
        guard case let .different(exp2, act2, _) = tree[1].kind
        else
        {
            XCTFail("Expected .different, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "modify")
        XCTAssertEqual(act2.value as? String, "add")
    }
    
    
    
    func testMultilineAllChangeTypes() throws
    {
        let expected    : String    = "keep\nremove\nmodify\nkeep2"
        let actual      : String    = "keep\nmodified\nkeep2\nadd"
        
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
        
        /// Line 1: `remove` vs `modified`
        /// Line 2: `modify` vs `keep2`
        /// Line 3: `keep2` vs `add`
        ///
        /// `CollectionDifference` aligns by content, not position.
        /// `keep2` appears in both strings, so the diff will show:
        /// - Line 1: `remove` -> `modified`    (`different`)
        /// - Line 2: `modify` removed          (`missing`)
        /// - Line 3: `add` inserted            (`unexpected`)
        XCTAssertEqual(tree.count, 3)
        XCTAssertEqual(tree[0].label, .line(1))
        XCTAssertEqual(tree[1].label, .line(2))
        XCTAssertEqual(tree[2].label, .line(3))
        
        
        
        guard case let .different(exp1, act1, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "remove")
        XCTAssertEqual(act1.value as? String, "modified")
        
        
        
        guard case let .missing(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "modify")
        
        
        
        guard case let .unexpected(act2) = tree[2].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[2].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, "add")
    }
    
    
    
    func testTrailingNewlineDifference() throws
    {
        let expected    : String    = "line0\nline1\n"
        let actual      : String    = "line0\nline1"
        
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
        
        /// `expected`  -> `["line0", "line1", ""]`
        /// `actual`    -> `["line0", "line1"]`
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .line(2))
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "")
    }
    
    
    
    func testBothHaveTrailingNewlines() throws
    {
        let expected    : String    = "line0\nline1\n"
        let actual      : String    = "line0\nline1\n"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard kind.isSame
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testOnlyNewlines() throws
    {
        let expected    : String    = "\n\n\n"
        let actual      : String    = "\n"
        
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
        
        /// `expected`  -> `["", "", "", ""]`
        /// `actual`    -> `["", ""]`
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .line(2))
        XCTAssertEqual(tree[1].label, .line(3))
        
        
        
        guard case let .missing(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "")
        
        
        
        guard case let .missing(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "")
    }
    
    
    
    func testEmptyLineInMiddle() throws
    {
        let expected    : String    = "a\n\nb\n"
        let actual      : String    = "a\nb"
        
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
        
        /// `expected`  -> `["a", "", "b", ""]`
        /// `actual`    -> `["a", "b"]`
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .line(1))
        XCTAssertEqual(tree[1].label, .line(3))
        
        
        
        guard case let .missing(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "")
        
        
        
        guard case let .missing(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "")
    }
    
    
    
    func testEmptyVsMultiline() throws
    {
        let expected    : String    = ""
        let actual      : String    = "line0\nline1"
        
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
        
        /// `expected`  -> `[""]`
        /// `actual`    -> `["line0", "line1"]`
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .line(0))
        XCTAssertEqual(tree[1].label, .line(1))
        
        
        
        guard case let .different(exp1, act1, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "")
        XCTAssertEqual(act1.value as? String, "line0")
        
        
        
        guard case let .unexpected(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpected, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(act2.value as? String, "line1")
    }
    
    
    
    func testSingleNewlineVsEmpty() throws
    {
        let expected    : String    = "\n"
        let actual      : String    = ""
        
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
        
        /// `expected`  -> `["", ""]`
        /// `actual`    -> `[""]`
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .line(1))
        
        
        
        guard case let .missing(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missing, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "")
    }
    
    
    
    func testBothSingleNewline() throws
    {
        let expected: String = "\n"
        
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
}
