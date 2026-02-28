//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class StringComparatorUnicodeTests: TestKitCase
{
    func testEmojiComparison()
    {
        let exp : String    = "hello 👋 world"
        let act : String    = "hello 🌎 world"
        
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
                    label:      .character(index: 6, count: 1),
                    expected:   "👋",
                    actual:     "🌎"
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCombiningChars()
    {
        /// Swift uses canonical equivalence, so precomposed (`é` -> `U+00E9`)
        /// and decomposed (`e` + `U+0301`) forms are considered equal.
        let exp : String    = "café"
        let act : String    = "cafe\u{0301}"
        
        let actual: DiffNodeKind = StringComparator.compare(
            expected:   exp,
            actual:     act
        )
        
        let expected: DiffNodeKind = .same
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testComplexEmoji()
    {
        let exp : String    = "😀"
        let act : String    = "🎭☹️❓"
        
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
                    expected:   exp,
                    actual:     act
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
