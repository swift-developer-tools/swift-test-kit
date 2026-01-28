//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKit
@testable import XCTestKitTestUtilities



internal final class StringComparatorUnicodeTests: XCTestKitCase
{
    func testEmojiComparison() throws
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testCombiningChars() throws
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testComplexEmoji() throws
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
        
        XCTKAssertEqual(expected, actual)
    }
}
