//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



internal final class FormatterNodeKindTests: XCTestCaseStopOnFail
{
    private typealias LK = TestKitCore.Formatter.LabelKind
    
    
    
    //  MARK: - Cycle
    
    func testCycleInExpected() throws
    {
        testCycle(.expected)
    }
    
    
    
    
    func testCycleInActual() throws
    {
        testCycle(.actual)
    }
    
    
    
    func testCycleInBoth() throws
    {
        testCycle(.both)
    }
    
    
    
    // MARK: - Same
    
    func testSameProducesNoOutput() throws
    {
        let node = DiffNode(
            label:  .root(typeName: typeName(of: 1)),
            kind:   .same
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String = ""
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Different
    
    func testDifferentLeafBool() throws
    {
        let exp         : Bool      = true
        let act         : Bool      = false
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(exp)
        \(LK.actual.rawValue)\(act)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafDouble() throws
    {
        let exp         : Double    = 1.0
        let act         : Double    = 2.0
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(exp)
        \(LK.actual.rawValue)\(act)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafInt() throws
    {
        let exp         : Int       = 10
        let act         : Int       = 20
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(exp)
        \(LK.actual.rawValue)\(act)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafString() throws
    {
        let exp         : String    = "hello"
        let act         : String    = "goodbye"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafEmptyString() throws
    {
        let exp         : String    = "hello"
        let act         : String    = ""
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafStringWithNewline() throws
    {
        let exp         : String    = "hello\nworld"
        let act         : String    = "hello"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp.escaped))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafStringWithTab() throws
    {
        let exp         : String    = "hello\tworld"
        let act         : String    = "hello"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp.escaped))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafStringWithCR() throws
    {
        let exp         : String    = "hello\rworld"
        let act         : String    = "hello"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp.escaped))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafStringWithBackslash() throws
    {
        let exp         : String    = "path\\to\\file"
        let act         : String    = "path/to/file"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp.escaped))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafStringWithNullTerminator() throws
    {
        let exp         : String    = "hello\0world"
        let act         : String    = "hello"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp.escaped))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDifferentLeafStringWithMultipleSpecialChars() throws
    {
        let exp         : String    = "a\nb\tc\rd\0e\\f"
        let act         : String    = "different"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeLeaf(
            label:      .root(typeName: typeName),
            expected:   exp,
            actual:     act
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(quote(exp.escaped))
        \(LK.actual.rawValue)\(quote(act))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Missing
    
    func testMissingIntElement() throws
    {
        let exp         : [Int]     = [1, 2, 3]
        let act         : [Int]     = [1, 2]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .index(2),
                    expected:   exp[2]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [2]
                \(LK.missing.rawValue)\(exp[2])
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMissingStringElement() throws
    {
        let exp         : [String]  = ["a", "b"]
        let act         : [String]  = ["b"]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .index(0),
                    expected:   exp[0]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.missing.rawValue)\(quote(exp[0]))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Unexpected
    
    func testUnexpectedIntElement() throws
    {
        let exp         : [Int]     = [1, 2]
        let act         : [Int]     = [0, 1, 2]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .index(0),
                    actual:     act[2]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [0]
                \(LK.unexpected.rawValue)\(act[2])
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUnexpectedStringElement() throws
    {
        let exp         : [String]  = ["b"]
        let act         : [String]  = ["a", "b"]
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .index(1),
                    actual:     act[1]
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [1]
                \(LK.unexpected.rawValue)\(quote(act[1]))
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Extensions

extension FormatterNodeKindTests
{
    /// Tests formatting a cycle detection.
    /// - Parameter location: The cycle location.
    private func testCycle(
        _ location: CycleLocation
    )
    {
        let exp         : String    = "node1"
        let act         : String    = "node2"
        let typeName    : String    = typeName(of: exp)
        
        let node = DiffNode.makeRoot(
            typeName:   typeName,
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeCycle(
                    label:      .property(name: "next"),
                    expected:   exp,
                    actual:     act,
                    location:   location
                )
            ]
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .next
                \(location.description)
        """
        
        XCTAssertEqual(expected, actual)
    }
}
