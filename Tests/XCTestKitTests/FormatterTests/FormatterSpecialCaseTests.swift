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



final class FormatterSpecialCaseTests: XCTestKitCase
{
    typealias LK = XCTestKit.Formatter.LabelKind
    
    
    
    // MARK: - Line/char diffs
    
    func testLineDiffWithSingleCharModification() throws
    {
        let exp         : String    = "line1\nhello"
        let act         : String    = "line1\nhallo"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "hello",
                    actual:     "hallo",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 1, count: 1),
                            expected:   "e",
                            actual:     "a"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 2
        \(LK.expected.rawValue)"hello"
        \(LK.actual.rawValue)"hallo"
        \(LK.changed.rawValue)character 2 ("e" → "a")
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testLineDiffWithMultipleCharModifications() throws
    {
        let exp         : String    = "line1\nabcdef"
        let act         : String    = "line1\naXcYef"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "abcdef",
                    actual:     "aXcYef",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 1, count: 1),
                            expected:   "b",
                            actual:     "X"
                        ),
                        
                        .makeLeaf(
                            label:      .character(index: 3, count: 1),
                            expected:   "d",
                            actual:     "Y"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 2
        \(LK.expected.rawValue)"abcdef"
        \(LK.actual.rawValue)"aXcYef"
        \(LK.changed.rawValue)character 2 ("b" → "X")
        \(LK.changed.rawValue)character 4 ("d" → "Y")
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testLineDiffWithMissingCharacters() throws
    {
        let exp         : String    = "line1\nhello"
        let act         : String    = "line1\nheo"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "hello",
                    actual:     "heo",
                    tree:
                    [
                        .makeMissing(
                            label:      .character(index: 2, count: 2),
                            expected:   "ll"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 2
        \(LK.expected.rawValue)"hello"
        \(LK.actual.rawValue)"heo"
        \(LK.missing.rawValue)characters 3-4 "ll"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testLineDiffWithUnexpectedCharacters() throws
    {
        let exp         : String    = "line1\nabc"
        let act         : String    = "line1\nabcdef"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "abc",
                    actual:     "abcdef",
                    tree:
                    [
                        .makeMissing(
                            label:      .character(index: 3, count: 3),
                            expected:   "def"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 2
        \(LK.expected.rawValue)"abc"
        \(LK.actual.rawValue)"abcdef"
        \(LK.missing.rawValue)characters 4-6 "def"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testLineDiffWithMixedChanges() throws
    {
        let exp         : String    = "line1\nabcdef"
        let act         : String    = "line1\naXefYZ"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .line(1),
                    expected:   "abcdef",
                    actual:     "aXefYZ",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 1, count: 1),
                            expected:   "b",
                            actual:     "X"
                        ),
                        
                        .makeMissing(
                            label:      .character(index: 2, count: 2),
                            expected:   "cd"
                        ),
                        
                        .makeUnexpected(
                            label:      .character(index: 4, count: 2),
                            actual:     "YZ"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 2
        \(LK.expected.rawValue)"abcdef"
        \(LK.actual.rawValue)"aXefYZ"
        \(LK.changed.rawValue)character 2 ("b" → "X")
        \(LK.missing.rawValue)characters 3-4 "cd"
        \(LK.unexpected.rawValue)2 characters at position 5 "YZ"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testLineDiffWithEmptyCharTree() throws
    {
        let exp         : String    = "line1\ncompletely different"
        let act         : String    = "line1\nxyz"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .line(1),
                    expected:   "completely different",
                    actual:     "xyz"
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 2
        \(LK.expected.rawValue)"completely different"
        \(LK.actual.rawValue)"xyz"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testMultipleLineDiffsWithCharSummaries() throws
    {
        let exp         : String    = "aaa\nbbb\nccc"
        let act         : String    = "aXa\nbbb\nccY"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .line(0),
                    expected:   "aaa",
                    actual:     "aXa",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 1, count: 1),
                            expected:   "a",
                            actual:     "X"
                        )
                    ]
                ),
                
                .makeStructural(
                    label:      .line(2),
                    expected:   "ccc",
                    actual:     "ccY",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 2, count: 1),
                            expected:   "c",
                            actual:     "Y"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    line 1
        \(LK.expected.rawValue)"aaa"
        \(LK.actual.rawValue)"aXa"
        \(LK.changed.rawValue)character 2 ("a" → "X")

    line 3
        \(LK.expected.rawValue)"ccc"
        \(LK.actual.rawValue)"ccY"
        \(LK.changed.rawValue)character 3 ("c" → "Y")
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testCharPathWithMultipleChars() throws
    {
        let exp         : String    = "hello"
        let act         : String    = "hABCo"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 1, count: 3),
                    expected:   "ell",
                    actual:     "ABC"
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    characters 2-4
        \(LK.expected.rawValue)"ell"
        \(LK.actual.rawValue)"ABC"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    // MARK: - Sets
    
    func testSetWithOnlyMissingElements() throws
    {
        let exp         : Set<String>   = ["a", "b", "c"]
        let act         : Set<String>   = ["a"]
        let typeName    : String        = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
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
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs:

    \(LK.missing.rawValue)"b"
    \(LK.missing.rawValue)"c"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testSetWithOnlyUnexpectedElements() throws
    {
        let exp         : Set<String>   = ["a"]
        let act         : Set<String>   = ["a", "b", "c"]
        let typeName    : String        = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
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
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs:

    \(LK.unexpected.rawValue)"b"
    \(LK.unexpected.rawValue)"c"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testSetWithMissingAndUnexpectedElements() throws
    {
        let exp         : Set<String>   = ["a", "b"]
        let act         : Set<String>   = ["a", "c"]
        let typeName    : String        = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .member,
                    expected:   "b"
                ),
                
                .makeUnexpected(
                    label:      .member,
                    actual:     "c"
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs:

    \(LK.missing.rawValue)"b"
    \(LK.unexpected.rawValue)"c"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testSetWithIntElements() throws
    {
        let exp         : Set<Int>  = [1, 2, 3]
        let act         : Set<Int>  = [1, 4]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .member,
                    expected:   2
                ),
                
                .makeMissing(
                    label:      .member,
                    expected:   3
                ),
                
                .makeUnexpected(
                    label:      .member,
                    actual:     4
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs:

    \(LK.missing.rawValue)2
    \(LK.missing.rawValue)3
    \(LK.unexpected.rawValue)4
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
    
    
    
    func testSetInStruct() throws
    {
        struct Container: Equatable
        {
            let tags: Set<String>
        }
        
        
        
        let exp         : Container     = .init(tags: ["a", "b"])
        let act         : Container     = .init(tags: ["a", "c"])
        let typeName    : String        = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "tags"),
                    expected:   exp.tags,
                    actual:     act.tags,
                    tree:
                    [
                        .makeMissing(
                            label:      .member,
                            expected:   "b"
                        ),
                        
                        .makeUnexpected(
                            label:      .member,
                            actual:     "c"
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
"""
\(typeName) differs at:

    .tags
        \(LK.missing.rawValue)"b"
        \(LK.unexpected.rawValue)"c"
"""
        
        XCTAssertEqual(Formatter.format(node), expected)
    }
}
