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



final class StringComparatorUnicodeTests: XCTestKitCase
{
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
        XCTAssertEqual(tree[0].label, .character(index: 6, count: 1))
        
        
        
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
        
        guard kind.isSame
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
        XCTAssertEqual(tree1[0].label, .character(index: 0, count: 1))
        
        
        
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
