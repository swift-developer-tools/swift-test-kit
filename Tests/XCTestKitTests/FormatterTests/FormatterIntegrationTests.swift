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



internal final class FormatterIntegrationTests: XCTestKitCase
{
    private typealias LK = XCTestKitCore.Formatter.LabelKind
    
    
    
    func testCycleDetection() throws
    {
        typealias Node = ComparatorCycleTests.Node
        
        let exp      = Node(value: 1)
        exp.next    = exp
        
        let act     = Node(value: 1)
        act.next    = act
        
        let typeName: String = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .next.some
                Cycle detected in both expected and actual values
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testRootLevelPrimitive() throws
    {
        let exp : Int   = 30
        let act : Int   = 20
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(LK.expected.rawValue)\(exp)
        \(LK.actual.rawValue)\(act)
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testArrayWithMixedChanges() throws
    {
        let exp         : [String]  = ["a", "b", "c", "d"]
        let act         : [String]  = ["a", "x", "d", "e"]
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            [1], character 1
                \(LK.expected.rawValue)\(quote(exp[1]))
                \(LK.actual.rawValue)\(quote(act[1]))

            [2]
                \(LK.missing.rawValue)\(quote(exp[2]))

            [3]
                \(LK.unexpected.rawValue)\(quote(act[3]))
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryWithNestedValueDiff() throws
    {
        struct Item: Equatable
        {
            let count: Int
        }
        
        let exp         : [String : Item]   = ["key": Item(count: 10)]
        let act         : [String : Item]   = ["key": Item(count: 20)]
        let typeName    : String            = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            ["key"].count
                \(LK.expected.rawValue)\(exp["key"]!.count)
                \(LK.actual.rawValue)\(act["key"]!.count)
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testSetMixedDifferences() throws
    {
        let exp         : Set<String>   = ["a", "b", "c"]
        let act         : Set<String>   = ["a", "d"]
        let typeName    : String        = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs:

            \(LK.missing.rawValue)"b"
            \(LK.missing.rawValue)"c"
            \(LK.unexpected.rawValue)"d"
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testMultiLineStringWithCharDiffs() throws
    {
        let exp         : String    = "line1\nhello\nline3"
        let act         : String    = "line1\nhallo\nline3"
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            line 2
                \(LK.expected.rawValue)"hello"
                \(LK.actual.rawValue)"hallo"
                \(LK.changed.rawValue)character 2 ("e" → "a")
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testStructWithSinglePropertyDifference() throws
    {
        struct User: Equatable
        {
            let name    : String
            let age     : Int
        }
        
        let exp         : User      = .init(name: "a", age: 30)
        let act         : User      = .init(name: "a", age: 20)
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .age
                \(LK.expected.rawValue)\(exp.age)
                \(LK.actual.rawValue)\(act.age)
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testNestedStructPathFlattening() throws
    {
        struct Inner: Equatable
        {
            let value: Int
        }
        
        struct Outer: Equatable
        {
            let inner: Inner
        }
        
        let exp         : Outer     = .init(inner: Inner(value: 10))
        let act         : Outer     = .init(inner: Inner(value: 20))
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: XCTKConfig.global.formatOptions
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .inner.value
                \(LK.expected.rawValue)\(exp.inner.value)
                \(LK.actual.rawValue)\(act.inner.value)
        """
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testTruncation() throws
    {
        let exp         : [Int]     = [1, 2, 3, 4, 5]
        let act         : [Int]     = [0, 0, 0, 0, 0]
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    XCTKConfig.global.diffOptions
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
        
        XCTKAssertEqual(expected, actual)
    }
}
