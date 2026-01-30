//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
@testable import XCTestKit
@testable import XCTestKitTestUtilities



internal final class FormatterTruncationTests: XCTestKitCase
{
    private typealias LK = XCTestKit.Formatter.LabelKind
    
    
    
    // MARK: - Max diffs
    
    func testMaxDiffsWithoutCountDiffs() throws
    {
        let options = XCTKFormatOptions(
            maxDiffs:       2,
            countDiffs:     false
        )
        
        let exp         : [Int]     = [1, 2, 3, 4, 5]
        let act         : [Int]     = [0, 0, 0, 0, 0]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:       (0..<5).map
            {
                .makeLeaf(
                    label:      .index($0),
                    expected:   exp[$0],
                    actual:     act[$0]
                )
            }
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.expected.rawValue)\(exp[0])
                \(LK.actual.rawValue)\(act[0])

            [1]
                \(LK.expected.rawValue)\(exp[1])
                \(LK.actual.rawValue)\(act[1])

            ... and more differences (limit: 2)
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testMaxDiffsWithCountDiffs() throws
    {
        let options = XCTKFormatOptions(
            maxDiffs:       2,
            countDiffs:     true
        )
        
        let exp         : [Int]     = [1, 2, 3, 4, 5]
        let act         : [Int]     = [0, 0, 0, 0, 0]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:       (0..<5).map
            {
                .makeLeaf(
                    label:      .index($0),
                    expected:   exp[$0],
                    actual:     act[$0]
                )
            }
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.expected.rawValue)\(exp[0])
                \(LK.actual.rawValue)\(act[0])

            [1]
                \(LK.expected.rawValue)\(exp[1])
                \(LK.actual.rawValue)\(act[1])

            ... and 3 more differences
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testMaxDiffsAtExactLimit() throws
    {
        let options = XCTKFormatOptions(maxDiffs: 3)
        
        let exp         : [Int]     = [1, 2, 3]
        let act         : [Int]     = [0, 0, 0]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:       (0..<3).map
            {
                .makeLeaf(
                    label:      .index($0),
                    expected:   exp[$0],
                    actual:     act[$0]
                )
            }
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.expected.rawValue)\(exp[0])
                \(LK.actual.rawValue)\(act[0])

            [1]
                \(LK.expected.rawValue)\(exp[1])
                \(LK.actual.rawValue)\(act[1])

            [2]
                \(LK.expected.rawValue)\(exp[2])
                \(LK.actual.rawValue)\(act[2])
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testMaxDiffsWithSetTree() throws
    {
        let options = XCTKFormatOptions(
            maxDiffs:       3,
            countDiffs:     true
        )
        
        let exp         : Set<Int>  = Set(1...10)
        let act         : Set<Int>  = []
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:       (1...10).map
            {
                .makeMissing(
                    label:      .member,
                    expected:   $0
                )
            }
        )
        
        let expected: String =
        """
        \(typeName) differs:

            \(LK.missing.rawValue)1
            \(LK.missing.rawValue)2
            \(LK.missing.rawValue)3

            ... and 7 more differences
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testMaxDiffsWithLineDiffs() throws
    {
        let options = XCTKFormatOptions(
            maxDiffs:       2,
            countDiffs:     true
        )
        
        let exp         : String    = "line1\nline2\nline3\nline4\nline5"
        let act         : String    = "AAAA\nBBBB\nCCCC\nDDDD\nEEEE"
        let expLines    : [String]  = exp.components(separatedBy: "\n")
        let actLines    : [String]  = act.components(separatedBy: "\n")
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:       (0..<5).map
            {
                .makeStructural(
                    label:      .line($0),
                    expected:   expLines[$0],
                    actual:     actLines[$0],
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   String(expLines[$0].first!),
                            actual:     String(actLines[$0].first!)
                        )
                    ]
                )
            }
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            line 1
                \(LK.expected.rawValue)\(quote(expLines[0]))
                \(LK.actual.rawValue)\(quote(actLines[0]))
                \(LK.changed.rawValue)character 1 ("l" → "A")

            line 2
                \(LK.expected.rawValue)\(quote(expLines[1]))
                \(LK.actual.rawValue)\(quote(actLines[1]))
                \(LK.changed.rawValue)character 1 ("l" → "B")

            ... and 3 more differences
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testMaxDiffsOfOne() throws
    {
        let options = XCTKFormatOptions(
            maxDiffs:       1,
            countDiffs:     true
        )
        
        let exp         : [Int]     = [1, 2, 3]
        let act         : [Int]     = [0, 0, 0]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:       (0..<3).map
            {
                .makeLeaf(
                    label:      .index($0),
                    expected:   exp[$0],
                    actual:     act[$0]
                )
            }
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.expected.rawValue)\(exp[0])
                \(LK.actual.rawValue)\(act[0])

            ... and 2 more differences
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testMaxDiffsWithNestedStructures() throws
    {
        struct Inner: Equatable
        {
            let a   : Int
            let b   : Int
        }
        
        struct Outer: Equatable
        {
            let x   : Inner
            let y   : Inner
        }
        
        let options = XCTKFormatOptions(
            maxDiffs:       2,
            countDiffs:     true
        )
        
        let exp : Outer     = .init(x: Inner(a: 1, b: 2), y: Inner(a: 3, b: 4))
        let act : Outer     = .init(x: Inner(a: 0, b: 0), y: Inner(a: 0, b: 0))
        
        let typeName: String = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "x"),
                    expected:   exp.x,
                    actual:     act.x,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "a"),
                            expected:   exp.x.a,
                            actual:     act.x.a
                        ),
                        
                        .makeLeaf(
                            label:      .property(name: "b"),
                            expected:   exp.x.b,
                            actual:     act.x.b
                        )
                    ]
                ),
                
                .makeStructural(
                    label:      .property(name: "y"),
                    expected:   exp.y,
                    actual:     act.y,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "a"),
                            expected:   exp.y.a,
                            actual:     act.y.a
                        ),
                        
                        .makeLeaf(
                            label:      .property(name: "b"),
                            expected:   exp.y.b,
                            actual:     act.y.b
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .x.a
                \(LK.expected.rawValue)\(exp.x.a)
                \(LK.actual.rawValue)\(act.x.a)

            .x.b
                \(LK.expected.rawValue)\(exp.x.b)
                \(LK.actual.rawValue)\(act.x.b)

            ... and 2 more differences
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    // MARK: Path
    
    func testPathTruncationForLongPath() throws
    {
        /// The path would be 32 characters: `.l2.l3.l4.l5.l6.l7.l8.l9.l10.val`.
        /// With a maximum line length of 30 and an indent of 1 (4 spaces),
        /// the available width is 26. The path should be middle-truncated.
        let options = XCTKFormatOptions(maxLineLength: 30)
        
        struct L10  : Equatable { let val   : Int }
        struct L9   : Equatable { let l10   : L10 }
        struct L8   : Equatable { let l9    : L9 }
        struct L7   : Equatable { let l8    : L8 }
        struct L6   : Equatable { let l7    : L7 }
        struct L5   : Equatable { let l6    : L6 }
        struct L4   : Equatable { let l5    : L5 }
        struct L3   : Equatable { let l4    : L4 }
        struct L2   : Equatable { let l3    : L3 }
        struct L1   : Equatable { let l2    : L2 }
        
        func makeNestedNode(
            depth       : Int,
            maxDepth    : Int
        ) -> DiffNode
        {
            guard depth != maxDepth
            else
            {
                return .makeLeaf(
                    label:      .property(name: "val"),
                    expected:   exp.l2.l3.l4.l5.l6.l7.l8.l9.l10.val,
                    actual:     act.l2.l3.l4.l5.l6.l7.l8.l9.l10.val
                )
            }
            
            let names: [String] = (2...10).map { "l\($0)" }
            
            return .makeStructural(
                label:      .property(name: names[depth]),
                expected:   0,
                actual:     0,
                tree:
                [
                    makeNestedNode(
                        depth:      depth + 1,
                        maxDepth:   maxDepth
                    )
                ]
            )
        }
        
        let exp: L1 = .init(
            l2: L2(l3: L3(l4: L4(
                l5: L5(l6: L6(l7: L7(l8: L8(l9: L9(l10: L10(val: 1))))))))
            )
        )
        
        let act: L1 = .init(
            l2: L2(l3: L3(l4: L4(
                l5: L5(l6: L6(l7: L7(l8: L8(l9: L9(l10: L10(val: 2))))))))
            )
        )
        
        let typeName: String = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                makeNestedNode(
                    depth:      0,
                    maxDepth:   9
                )
            ]
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .l2.l3.l4.l....l9.l10.val
                \(LK.expected.rawValue)\(exp.l2.l3.l4.l5.l6.l7.l8.l9.l10.val)
                \(LK.actual.rawValue)\(act.l2.l3.l4.l5.l6.l7.l8.l9.l10.val)
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    // MARK: - Value
    
    func testValueTruncationExceedsMaxLineLength() throws
    {
        /// Available width = 50 - 0 (indent) - 12 (label) = 38
        /// Value = 100 + 2 (quotes) = 102
        /// Truncated to 38 characters: 35 `a` characters + 3 (ellipsis)
        let options = XCTKFormatOptions(maxLineLength: 50)
        
        let truncatedExp    : String    = .init(repeating: "a", count: 35)
        let exp             : String    = .init(repeating: "a", count: 100)
        let act             : String    = "short"
        let typeName        : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(truncatedExp + "..."))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testValueTruncationRespectsMinimumWidth() throws
    {
        /// Available width = 20 - 0 (indent) - 12 (label) = 8
        /// Minimum line width = 20
        /// Truncated to 20 characters: 17 `a` characters + 3 (ellipsis)
        let options = XCTKFormatOptions(maxLineLength: 20)
        
        let shortExp    : String    = .init(repeating: "a", count: 17)
        let exp         : String    = .init(repeating: "a", count: 50)
        let act         : String    = "b"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(shortExp + "..."))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testValueTruncationAtNestedIndent() throws
    {
        struct Container: Equatable
        {
            let data: String
        }
        
        /// Available width = 60 - 8 (indent) - 12 (label) = 40
        /// Minimum line width = 20
        /// Truncated to 40 characters: 37 `a` characters + 3 (ellipsis)
        let options = XCTKFormatOptions(maxLineLength: 60)
        
        let shortData   : String        = .init(repeating: "a", count: 37)
        let longData    : String        = .init(repeating: "a", count: 100)
        let exp         : Container     = .init(data: longData)
        let act         : Container     = .init(data: "short")
        let typeName    : String        = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "data"),
                    expected:   exp.data,
                    actual:     act.data
                )
            ]
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .data
                \(LK.expected.rawValue)\(quote(shortData + "..."))
                \(LK.actual.rawValue)\(quote(act.data))
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testValueTruncationAtMinimumWidth() throws
    {
        /// Available width = 30 - 12 (indent) - 12 (label) = 6
        /// Minimum line width = 20
        /// Truncated to 20 characters: 17 `a` characters + 3 (ellipsis)
        let options = XCTKFormatOptions(maxLineLength: 30)
        
        struct L3   : Equatable { let data  : String }
        struct L2   : Equatable { let l3    : L3 }
        struct L1   : Equatable { let l2    : L2 }
        
        let shortData   : String    = .init(repeating: "a", count: 17)
        let longData    : String    = .init(repeating: "a", count: 50)
        let exp         : L1        = .init(l2: L2(l3: L3(data: longData)))
        let act         : L1        = .init(l2: L2(l3: L3(data: "short")))
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "l2"),
                    expected:   exp.l2,
                    actual:     act.l2,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "l3"),
                            expected:   exp.l2.l3,
                            actual:     act.l2.l3,
                            tree:
                            [
                                .makeLeaf(
                                    label:      .property(name: "data"),
                                    expected:   exp.l2.l3.data,
                                    actual:     act.l2.l3.data
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .l2.l3.data
                \(LK.expected.rawValue)\(quote(shortData + "..."))
                \(LK.actual.rawValue)\(quote(act.l2.l3.data))
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    // MARK: - Indentation
    
    func testZeroIndentationSpaces() throws
    {
        struct User: Equatable
        {
            let age: Int
        }
        
        let options = XCTKFormatOptions(indentationSpaces: 0)
        
        let exp         : User      = .init(age: 30)
        let act         : User      = .init(age: 20)
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "age"),
                    expected:   exp.age,
                    actual:     act.age
                )
            ]
        )
        
        let expected: String =
        """
        \(typeName) differs at:

        .age
        \(LK.expected.rawValue)\(exp.age)
        \(LK.actual.rawValue)\(act.age)
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testCustomIndentationSpaces() throws
    {
        struct User: Equatable
        {
            let age: Int
        }
        
        let options = XCTKFormatOptions(indentationSpaces: 2)
        
        let exp         : User      = .init(age: 30)
        let act         : User      = .init(age: 20)
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "age"),
                    expected:   exp.age,
                    actual:     act.age
                )
            ]
        )
        
        let expected: String =
        """
        \(typeName) differs at:

          .age
            \(LK.expected.rawValue)\(exp.age)
            \(LK.actual.rawValue)\(act.age)
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
    
    
    
    func testValueTruncationForNonStringType() throws
    {
        let options = XCTKFormatOptions(maxLineLength: 30)
        
        let exp         : [Int]     = Array(1...40)
        let act         : [Int]     = []
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)[1, 2, 3, 4, 5, 6...
        \(LK.actual.rawValue)\(act)
        """
        
        XCTKAssertEqual(Formatter.format(node, options: options), expected)
    }
}
