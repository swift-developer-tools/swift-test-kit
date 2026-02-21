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



internal final class FormatterTruncationTests: TestKitCase
{
    private typealias LK = TestKitCore.Formatter.LabelKind
    
    
    
    // MARK: - Max diffs
    
    func testMaxDiffsWithoutCountDiffs()
    {
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 2, countDiffs: false)
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithCountDiffs()
    {
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 2, countDiffs: true)
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsAtExactLimit()
    {
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 3)
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithSetTree()
    {
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 3, countDiffs: true)
        )
        
        let expected: String =
        """
        \(typeName) differs:

            \(LK.missing.rawValue)1
            \(LK.missing.rawValue)2
            \(LK.missing.rawValue)3

            ... and 7 more differences
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithLineDiffs()
    {
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 2, countDiffs: true)
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsOfOne()
    {
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 1, countDiffs: true)
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.expected.rawValue)\(exp[0])
                \(LK.actual.rawValue)\(act[0])

            ... and 2 more differences
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithNestedStructures()
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxDiffs: 2, countDiffs: true)
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: Path
    
    func testPathTruncationForLongPath()
    {
        /// The path would be 32 characters: `.l2.l3.l4.l5.l6.l7.l8.l9.l10.val`.
        /// With a maximum line length of 30 and an indent of 1 (4 spaces),
        /// the available width is 26. The path should be middle-truncated.
        
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxLineLength: 30)
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .l2.l3.l4.l....l9.l10.val
                \(LK.expected.rawValue)\(exp.l2.l3.l4.l5.l6.l7.l8.l9.l10.val)
                \(LK.actual.rawValue)\(act.l2.l3.l4.l5.l6.l7.l8.l9.l10.val)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Value
    
    func testValueTruncationExceedsMaxLineLength()
    {
        /// Available width = 50 - 0 (indent) - 12 (label) = 38
        /// Value = 100 + 2 (quotes) = 102
        /// Truncated to 38 characters: 35 `a` characters + 3 (ellipsis)
        
        let truncatedExp    : String    = .init(repeating: "a", count: 35)
        let exp             : String    = .init(repeating: "a", count: 100)
        let act             : String    = "short"
        let typeName        : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxLineLength: 50)
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(truncatedExp + "..."))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testValueTruncationRespectsMinimumWidth()
    {
        /// Available width = 20 - 0 (indent) - 12 (label) = 8
        /// Minimum line width = 20
        /// Truncated to 20 characters: 17 `a` characters + 3 (ellipsis)
        
        let shortExp    : String    = .init(repeating: "a", count: 17)
        let exp         : String    = .init(repeating: "a", count: 50)
        let act         : String    = "b"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxLineLength: 20)
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(shortExp + "..."))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testValueTruncationAtNestedIndent()
    {
        struct Container: Equatable
        {
            let data: String
        }
        
        /// Available width = 60 - 8 (indent) - 12 (label) = 40
        /// Minimum line width = 20
        /// Truncated to 40 characters: 37 `a` characters + 3 (ellipsis)
        
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxLineLength: 60)
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .data
                \(LK.expected.rawValue)\(quote(shortData + "..."))
                \(LK.actual.rawValue)\(quote(act.data))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testValueTruncationAtMinimumWidth()
    {
        /// Available width = 30 - 12 (indent) - 12 (label) = 6
        /// Minimum line width = 20
        /// Truncated to 20 characters: 17 `a` characters + 3 (ellipsis)
        
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxLineLength: 30)
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .l2.l3.data
                \(LK.expected.rawValue)\(quote(shortData + "..."))
                \(LK.actual.rawValue)\(quote(act.l2.l3.data))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Indentation
    
    func testZeroIndentationSpaces()
    {
        struct User: Equatable
        {
            let age: Int
        }
        
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(indentationSpaces: 0)
        )
        
        let expected: String =
        """
        \(typeName) differs at:

        .age
        \(LK.expected.rawValue)\(exp.age)
        \(LK.actual.rawValue)\(act.age)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomIndentationSpaces()
    {
        struct User: Equatable
        {
            let age: Int
        }
        
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
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(indentationSpaces: 2)
        )
        
        let expected: String =
        """
        \(typeName) differs at:

          .age
            \(LK.expected.rawValue)\(exp.age)
            \(LK.actual.rawValue)\(act.age)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testValueTruncationForNonStringType()
    {
        let exp         : [Int]     = Array(1...40)
        let act         : [Int]     = []
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init(maxLineLength: 30)
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)[1, 2, 3, 4, 5, 6...
        \(LK.actual.rawValue)\(act)
        """
        
        XCTAssertEqual(expected, actual)
    }
}
