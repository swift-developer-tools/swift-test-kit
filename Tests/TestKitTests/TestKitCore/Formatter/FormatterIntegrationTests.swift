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



internal final class FormatterIntegrationTests: TestKitCase
{
    private typealias LK = TestKitCore.Formatter.LabelKind
    
    
    
    func testCycleDetection()
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
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .next.some
                Cycle detected in both expected and actual values
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testRootLevelPrimitive()
    {
        let exp : Int   = 30
        let act : Int   = 20
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
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
    
    
    
    func testArrayWithMixedChanges()
    {
        let exp         : [String]  = ["a", "b", "c", "d"]
        let act         : [String]  = ["a", "x", "d", "e"]
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDictionaryWithNestedValueDiff()
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
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            ["key"].count
                \(LK.expected.rawValue)\(exp["key"]!.count)
                \(LK.actual.rawValue)\(act["key"]!.count)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSetMixedDifferences()
    {
        let exp         : Set<String>   = ["a", "b", "c"]
        let act         : Set<String>   = ["a", "d"]
        let typeName    : String        = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs:

            \(LK.missing.rawValue)"b"
            \(LK.missing.rawValue)"c"
            \(LK.unexpected.rawValue)"d"
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiLineStringWithCharDiffs()
    {
        let exp         : String    = "line1\nhello\nline3"
        let act         : String    = "line1\nhallo\nline3"
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            line 2
                \(LK.expected.rawValue)"hello"
                \(LK.actual.rawValue)"hallo"
                \(LK.changed.rawValue)character 2 ("e" → "a")
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStructWithSinglePropertyDifference()
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
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
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
    
    
    
    func testNestedStructPathFlattening()
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
            options:    .init()
        )
        
        let actual: String = Formatter.formatDiff(
            node,
            options: .init()
        )
        
        let expected: String =
        """
        \(typeName) differs at:

            .inner.value
                \(LK.expected.rawValue)\(exp.inner.value)
                \(LK.actual.rawValue)\(act.inner.value)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTruncation()
    {
        let exp         : [Int]     = [1, 2, 3, 4, 5]
        let act         : [Int]     = [0, 0, 0, 0, 0]
        let typeName    : String    = typeName(of: exp)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
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
}
