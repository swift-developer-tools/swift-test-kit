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



final class StringComparatorTests: XCTestKitCase
{
    // MARK: - Single-line
    
    func testSingleLineEqualStrings() throws
    {
        let expected: String = "hello"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = kind
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
        XCTAssertEqual(tree1[0].label, .character(1))
        
        
        
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
        
        guard case .same = kind
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
        XCTAssertEqual(tree[0].label, .character(0))
        
        
        
        guard case let .unexpectedElement(act2) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
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
        XCTAssertEqual(tree[0].label, .character(0))
        
        
        
        guard case let .missingElement(exp2) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
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
        XCTAssertEqual(tree[0].label, .character(0))
        
        
        
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
        XCTAssertEqual(tree[0].label, .character(4))
        
        
        
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
        XCTAssertEqual(tree[0].label, .character(3))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
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
        XCTAssertEqual(tree[0].label, .character(0))
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
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
        XCTAssertEqual(tree[0].label, .character(0))
        
        
        
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
        XCTAssertEqual(tree[0].label, .character(6))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
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
        XCTAssertEqual(tree[0].label, .character(5))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "\t")
        XCTAssertEqual(act.value as? String, " ")
    }
    
    
    
    // MARK: - Multi-line
    
    func testMultiLineEqualStrings() throws
    {
        let expected: String = "line0\nline1\nline2"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = kind
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
        XCTAssertEqual(tree2[0].label, .character(4))
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
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
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
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
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
        
        
        
        guard case let .unexpectedElement(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[1].kind)")
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
        
        
        
        guard case let .missingElement(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "modify")
        
        
        
        guard case let .unexpectedElement(act2) = tree[2].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[2].kind)")
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
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
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
        
        guard case .same = kind
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
        
        
        
        guard case let .missingElement(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "")
        
        
        
        guard case let .missingElement(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
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
        
        
        
        guard case let .missingElement(exp1) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "")
        
        
        
        guard case let .missingElement(exp2) = tree[1].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[1].kind)")
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
        
        
        
        guard case let .unexpectedElement(act2) = tree[1].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[1].kind)")
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
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
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
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    // MARK: - Normalization
    
    func testNewlineNormalizationCRLF() throws
    {
        let expected    : String    = "line0\r\nline1"
        let actual      : String    = "line0\nline1"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testNewlineNormalizationCR() throws
    {
        let expected    : String    = "line0\rline1"
        let actual      : String    = "line0\nline1"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testMixedNewlineNormalization() throws
    {
        let expected    : String    = "line0\r\nline1\r\nline3"
        let actual      : String    = "line0\nline1\nline3"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testMixedCRLFAndCRNormalization() throws
    {
        let expected    : String    = "line0\r\nline1\rline3"
        let actual      : String    = "line0\nline1\nline3"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    // MARK: - Character threshold
    
    func testCharDiffThresholdCollapsesWhenExceeded() throws
    {
        let expected    : String    = "12345"
        let actual      : String    = "54321"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.75)
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testCharDiffThresholdPreservesWhenNotExceeded() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "hallo"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.75)
        )
        
        guard case let .different(_, _, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(1))
    }
    
    
    
    func testCharDiffThresholdWithEmptyStrings() throws
    {
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   "",
            actual:     "",
            options:    XCTKDiffOptions(characterDiffThreshold: 0.5)
        )
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testCharDiffThresholdAtExactBoundary() throws
    {
        /// Exactly 50% of characters are changed, and the threshold is 50%.
        /// The character diff must be preserved. The changes will be
        /// coalesced into a single node, however, rather than emitting one
        /// node for each changed character, since the changes are adjacent.
        let expected    : String    = "abcd"
        let actual      : String    = "abXX"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.5)
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
        XCTAssertEqual(tree[0].label, .character(2))
    }
    
    
    
    func testCharDiffThresholdCompletelyDifferentWithThreshold() throws
    {
        let expected    : String    = "abc"
        let actual      : String    = "xyz"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.9)
        )
        
        guard case let .different(exp, act, tree) = kind
        else
        {
            XCTFail("Expected .different, got \(kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testCharDiffThresholdCompletelyDifferentNoThreshold() throws
    {
        let expected    : String    = "abc"
        let actual      : String    = "xyz"
        
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
        
        /// The diff will produce removed `{0, 1, 2}` and inserted `{0, 1, 2}`.
        /// At index `0`, both have entries, so the coalescing logic will
        /// accumulate all three characters in each of `expected` and `actual`,
        /// since there are entries at each index. The tree will contain the
        /// single coalesced node.
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .character(0))
    }
    
    
    
    func testThresholdAppliesToIndividualLines() throws
    {
        let expected    : String    = "keep\n12345\nkeep"
        let actual      : String    = "keep\n54321\nkeep"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(characterDiffThreshold: 0.5)
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
        
        XCTAssertEqual(exp.value as? String, "12345")
        XCTAssertEqual(act.value as? String, "54321")
        XCTAssertTrue(tree2.isEmpty)
    }
    
    
    
    // MARK: - Character coalescing
    
    func testCharCoalescingAdjacentRemovals() throws
    {
        let expected    : String    = "abcdef"
        let actual      : String    = "adef"
        
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
        XCTAssertEqual(tree[0].label, .character(1))
        
        
        
        guard case let .missingElement(exp) = tree[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "bc")
    }
    
    
    
    func testCharCoalescingAdjacentInsertions() throws
    {
        let expected    : String    = "adef"
        let actual      : String    = "abcdef"
        
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
        XCTAssertEqual(tree[0].label, .character(1))
        
        
        
        guard case let .unexpectedElement(act) = tree[0].kind
        else
        {
            XCTFail("Expected .unexpectedElement, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(act.value as? String, "bc")
    }
    
    
    
    func testCharCoalescingMixedChanges() throws
    {
        let expected    : String    = "abcdef"
        let actual      : String    = "aXXcYYf"
        
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
        XCTAssertEqual(tree[0].label, .character(1))
        XCTAssertEqual(tree[1].label, .character(3))
        
        
        
        guard case let .different(exp1, act1, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? String, "b")
        XCTAssertEqual(act1.value as? String, "XX")
        
        
        
        guard case let .different(exp2, act2, _) = tree[1].kind
        else
        {
            XCTFail("Expected .different, got \(tree[1].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? String, "de")
        XCTAssertEqual(act2.value as? String, "YY")
    }
    
    
    
    // MARK: - Unicode
    
    func testEmojiComparison() throws
    {
        let expected    : String    = "hello 👋 world"
        let actual      : String    = "hello 🌎 world"
        
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
        XCTAssertEqual(tree[0].label, .character(6))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "👋")
        XCTAssertEqual(act.value as? String, "🌎")
    }
    
    
    
    func testCombiningChars() throws
    {
        /// Swift uses canonical equivalence, so precomposed (`é` -> `U+00E9`)
        /// and decomposed (`e` + `U+0301`) forms are considered equal.
        let expected    : String    = "café"
        let actual      : String    = "cafe\u{0301}"
        
        let kind: DiffNodeKind = StringComparator.compare(
            expected:   expected,
            actual:     actual
        )
        
        guard case .same = kind
        else
        {
            XCTFail("Expected .same, got \(kind)")
            return
        }
    }
    
    
    
    func testComplexEmoji() throws
    {
        let expected    : String    = "😀"
        let actual      : String    = "🎭☹️❓"
        
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
        
        /// The diff will produce removed `{0}` and inserted `{0, 1, 2}`.
        /// At index `0`, both have entries, so the coalescing logic will
        /// accumulate the only character in `expected` and all three
        /// characters in `actual`, since there are entries at each index.
        /// The tree will contain the single coalesced node.
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .character(0))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, expected)
        XCTAssertEqual(act.value as? String, actual)
        XCTAssertTrue(tree2.isEmpty)
    }
}
