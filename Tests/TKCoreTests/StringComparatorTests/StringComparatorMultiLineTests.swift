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



internal final class StringComparatorMultiLineTests: XCTestCaseStopOnFail
{
    func testMultiLineEqualStrings() throws
    {
        let exp: String = "line0\nline1\nline2"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     exp
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiLineModifiedLine() throws
    {
        let exp : String    = "line0\nline1\nline2"
        let act : String    = "line0\nlineX\nline2"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "line1",
                    actual:     "lineX",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 4, count: 1),
                            expected:   "1",
                            actual:     "X"
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiLineMissingLine() throws
    {
        let exp : String    = "line0\nline1\nline2"
        let act : String    = "line0\nline2"
        
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
                    label:      .line(1),
                    expected:   "line1"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiLineUnexpectedLine() throws
    {
        let exp : String    = "line0\nline2"
        let act : String    = "line0\nline1\nline2"
        
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
                    label:      .line(1),
                    actual:     "line1"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleLineVsMultiLine() throws
    {
        let exp : String    = "single"
        let act : String    = "multiple\nlines"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeStructural(
                    label:      .line(0),
                    expected:   "single",
                    actual:     "multiple",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   "s",
                            actual:     "mult"
                        ),
                        
                        .makeLeaf(
                            label:      .character(index: 2, count: 2),
                            expected:   "ng",
                            actual:     "p"
                        )
                    ]
                ),
                
                .makeUnexpected(
                    label:      .line(1),
                    actual:     "lines"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleLineChanges() throws
    {
        let exp : String    = "keep\nremove\nmodify"
        let act : String    = "keep\nchange\nadd"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "remove",
                    actual:     "change",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   "r",
                            actual:     "chang"
                        ),
                        
                        .makeMissing(
                            label:      .character(index: 2, count: 4),
                            expected:   "move"
                        )
                    ]
                ),
                
                .makeStructural(
                    label:      .line(2),
                    expected:   "modify",
                    actual:     "add",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 2),
                            expected:   "mo",
                            actual:     "a"
                        ),
                        
                        .makeLeaf(
                            label:      .character(index: 3, count: 3),
                            expected:   "ify",
                            actual:     "d"
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultilineAllChangeTypes() throws
    {
        let exp : String    = "keep\nremove\nmodify\nkeep2"
        let act : String    = "keep\nmodified\nkeep2\nadd"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "remove",
                    actual:     "modified",
                    tree:
                    [
                        .makeMissing(
                            label:      .character(index: 0, count: 2),
                            expected:   "re"
                        ),
                        
                        .makeLeaf(
                            label:      .character(index: 4, count: 1),
                            expected:   "v",
                            actual:     "difi"
                        ),
                        
                        .makeUnexpected(
                            label:      .character(index: 6, count: 1),
                            actual:     "d"
                        )
                    ]
                ),
                
                .makeMissing(
                    label:      .line(2),
                    expected:   "modify"
                ),
            
                .makeUnexpected(
                    label:      .line(3),
                    actual:     "add"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTrailingNewlineDifference() throws
    {
        let exp : String    = "line0\nline1\n"
        let act : String    = "line0\nline1"
        
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
                    label:      .line(2),
                    expected:   ""
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testBothHaveTrailingNewlines() throws
    {
        let exp: String = "line0\nline1\n"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     exp
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOnlyNewlines() throws
    {
        let exp : String    = "\n\n\n"
        let act : String    = "\n"
        
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
                    label:      .line(2),
                    expected:   ""
                ),
                
                .makeMissing(
                    label:      .line(3),
                    expected:   ""
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEmptyLineInMiddle() throws
    {
        let exp : String    = "a\n\nb\n"
        let act : String    = "a\nb"
        
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
                    label:      .line(1),
                    expected:   ""
                ),
                
                .makeMissing(
                    label:      .line(3),
                    expected:   ""
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEmptyVsMultiline() throws
    {
        let exp : String    = ""
        let act : String    = "line0\nline1"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .different(
            expected:   DiffValue(exp),
            actual:     DiffValue(act),
            tree:
            [
                .makeStructural(
                    label:      .line(0),
                    expected:   "",
                    actual:     "line0",
                    tree:
                    [
                        .makeUnexpected(
                            label:      .character(index: 0, count: 5),
                            actual:     "line0"
                        )
                    ]
                ),
                
                .makeUnexpected(
                    label:      .line(1),
                    actual:     "line1"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleNewlineVsEmpty() throws
    {
        let exp : String    = "\n"
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
                    label:      .line(1),
                    expected:   ""
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testBothSingleNewline() throws
    {
        let exp: String = "\n"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     exp
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
}
