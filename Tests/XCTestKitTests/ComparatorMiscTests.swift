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



final class ComparatorMiscTests: XCTestKitCase
{
    // MARK: - Primitive types
    
    func testBooleanEqualValues() throws
    {
        let expected: Bool = true
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testBooleanDifferentValues() throws
    {
        let expected    : Bool    = true
        let actual      : Bool    = false
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Bool, expected)
        XCTAssertEqual(act as? Bool, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testIntegerEqualValues() throws
    {
        let expected: Int = 10
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, expected)
    }
    
    
    
    func testIntegerDifferentValues() throws
    {
        let expected    : Int   = 10
        let actual      : Int   = 20
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, expected)
        XCTAssertEqual(act as? Int, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testFloatEqualValues() throws
    {
        let expected: Float64 = 10 / 3
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Float64, expected)
    }
    
    
    
    func testFloatDifferentValues() throws
    {
        let expected    : Float64   = 10 / 3
        let actual      : Float64   = 20 / 3
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Float64, expected)
        XCTAssertEqual(act as? Float64, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testStringEqualValues() throws
    {
        let expected: String = "hello"
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, expected)
    }
    
    
    
    func testStringDifferentValues() throws
    {
        let expected    : String    = "hello"
        let actual      : String    = "goodbye"
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, expected)
        XCTAssertEqual(act as? String, actual)
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .character(0))
        XCTAssertEqual(tree[1].label, .character(5))
    }
    
    
    
    // MARK: - Reference types
    
    func testClassWithValueBasedEquality() throws
    {
        /// Check whether structural diffing works correctly when classes use
        /// property-based equality (`==`).
        
        final class User: Equatable
        {
            let name    : String
            let age     : Int
            
            init(
                name    : String,
                age     : Int
            )
            {
                self.name   = name
                self.age    = age
            }
            
            static func == (
                lhs : User,
                rhs : User
            ) -> Bool
            {
                return lhs.name == rhs.name
                    && lhs.age == rhs.age
            }
        }
        
        
        
        let expected    = User(name: "Someone", age: 30)
        let actual      = User(name: "Someone", age: 20)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "age"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 30)
        XCTAssertEqual(act as? Int, 20)
    }
    
    
    
    // MARK: - Closures
    
    func testStructWithClosure() throws
    {
        /// The closures are different, but a closure cannot conform to
        /// `Equatable`, and the `Equatable` implementation does not consider
        /// them. The closures use `String(describing:)`, which returns
        /// `"(Function)"` for both.
        
        struct Handler: Equatable
        {
            let id      : Int
            let name    : String
            let action  : () -> Int
            
            static func == (
                lhs : Handler,
                rhs : Handler
            ) -> Bool
            {
                return lhs.id == rhs.id
                    && lhs.name == rhs.name
            }
        }
        
        
        
        let expected = Handler(
            id:         1,
            name:       "a",
            action:     { return 2 + 2 }
        )
        
        let actual = Handler(
            id:         1,
            name:       "b",
            action:     { return 3 * 3 }
        )
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "name"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? String, "a")
        XCTAssertEqual(act as? String, "b")
    }
    
    
    
    // MARK: - Standard library types
    
    func testDataEqualValues() throws
    {
        let expected = Data([0x00, 0x01, 0x02, 0x03])
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testDataDifferentValues() throws
    {
        let expected    = Data([0x00, 0x01, 0x02, 0x03])
        let actual      = Data([0x00, 0x01, 0xFF, 0x03])
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp1 as? Data, expected)
        XCTAssertEqual(act1 as? Data, actual)
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "bytes"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .index(2))
        
        
        
        guard case let .different(exp2, act2, _) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp2 as? UInt8, 0x02)
        XCTAssertEqual(act2 as? UInt8, 0xFF)
    }
    
    
    
    func testDataDifferentLengths() throws
    {
        let expected    = Data([0x00, 0x01, 0x02])
        let actual      = Data([0x00, 0x01])
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp1 as? Data, expected)
        XCTAssertEqual(act1 as? Data, actual)
        XCTAssertEqual(tree1.count, 2)
        XCTAssertEqual(tree1[0].label, .property(name: "count"))
        XCTAssertEqual(tree1[1].label, .property(name: "bytes"))
        
        
        
        guard case let .different(exp1, act1, _) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(exp1 as? Int, expected.count)
        XCTAssertEqual(act1 as? Int, actual.count)
        
        
        
        guard case let .different(_, _, tree2) = tree1[1].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[1].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .index(2))
        
        
        
        guard case let .missingElement(exp) = tree2[0].kind
        else
        {
            XCTFail("Expected .missingElement, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? UInt8, 0x02)
    }
    
    
    
    func testDateEqualValues() throws
    {
        let expected = Date(timeIntervalSince1970: 1_000_000)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testDateDifferentValues() throws
    {
        let expected    = Date(timeIntervalSince1970: 1_000_000)
        let actual      = Date(timeIntervalSince1970: 2_000_000)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, _) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Date, expected)
        XCTAssertEqual(act as? Date, actual)
    }
    
    
    
    func testOptionSetEqualValues() throws
    {
        struct Permissions: OptionSet, Equatable
        {
            let rawValue: Int
            
            static let read     = Permissions(rawValue: 1 << 0)
            static let write    = Permissions(rawValue: 1 << 1)
            static let execute  = Permissions(rawValue: 1 << 2)
        }
        
        
        
        let expected: Permissions = [.read, .write]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testOptionSetDifferentValues() throws
    {
        struct Permissions: OptionSet, Equatable
        {
            let rawValue: Int
            
            static let read     = Permissions(rawValue: 1 << 0)
            static let write    = Permissions(rawValue: 1 << 1)
            static let execute  = Permissions(rawValue: 1 << 2)
        }
        
        
        
        let expected    : Permissions = [.read, .write]
        let actual      : Permissions = [.read, .execute]
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "rawValue"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, expected.rawValue)
        XCTAssertEqual(act as? Int, actual.rawValue)
    }
    
    
    
    func testRangeEqualValues() throws
    {
        let expected: Range<Int> = 0..<10
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testRangeDifferentValues() throws
    {
        let expected    : Range<Int>    = 0..<10
        let actual      : Range<Int>    = 0..<5
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "upperBound"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
        XCTAssertEqual(act as? Int, 5)
    }
    
    
    
    func testClosedRangeDifferentValues() throws
    {
        let expected    : ClosedRange<Int>  = 0...10
        let actual      : ClosedRange<Int>  = 5...10
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .property(name: "lowerBound"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 0)
        XCTAssertEqual(act as? Int, 5)
    }
    
    
    
    func testURLEqualValues() throws
    {
        let expected = URL(string: "https://example.com/page")!
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testURLDifferentValues() throws
    {
        let expected    = URL(string: "https://example.com/page1")!
        let actual      = URL(string: "https://example.com/page2")!
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, _) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? URL, expected)
        XCTAssertEqual(act as? URL, actual)
    }
    
    
    
    func testUUIDEqualValues() throws
    {
        let expected = UUID(
            uuidString: "00000000-0000-0000-0000-000000000001"
        )!
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected
        )
        
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testUUIDDifferentValues() throws
    {
        let expected = UUID(
            uuidString: "00000000-0000-0000-0000-000000000001"
        )!
        
        let actual = UUID(
            uuidString: "00000000-0000-0000-0000-000000000002"
        )!
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, _) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? UUID, expected)
        XCTAssertEqual(act as? UUID, actual)
    }
    
    
    
    // MARK: - Big data
    
    func testLargeArraySingleDifference() throws
    {
        let expected    : [Int]     = Array(0..<10_000)
        var actual      : [Int]     = Array(0..<10_000)
        
        actual[5000] = -1
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(5000))
    }
    
    
    
    func testLargeArrayManyDifferences() throws
    {
        let expected    : [Int]     = Array(0..<10_000)
        var actual      : [Int]     = Array(0..<10_000)
        
        for i in stride(from: 0, to: 10_000, by: 100)
        {
            actual[i] = -1
        }
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 100)
    }
    
    
    
    func testLargeDictionarySingleDifference() throws
    {
        var expected    : [Int : Int]   = [:]
        var actual      : [Int : Int]   = [:]
        
        for i in 0..<10_000
        {
            expected[i]     = i
            actual[i]       = i
        }
        
        actual[5000] = -1
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 1)
        
        XCTAssertEqual(
            tree[0].label,
            .key(description: "5000", typeName: "Int")
        )
    }
    
    
    
    func testLargeSetManyDifferences() throws
    {
        let expected    : Set<Int>  = Set(0..<10_000)
        let actual      : Set<Int>  = Set(500..<10_500)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        
        
        let missingCount: Int = tree.filter
        {
            if case .missingElement = $0.kind
            {
                return true
            }
            
            return false
        }.count
        
        XCTAssertEqual(missingCount, 500)
        
        
        
        let unexpectedCount: Int = tree.filter
        {
            if case .unexpectedElement = $0.kind
            {
                return true
            }
            
            return false
        }.count
        
        XCTAssertEqual(unexpectedCount, 500)
    }
}
