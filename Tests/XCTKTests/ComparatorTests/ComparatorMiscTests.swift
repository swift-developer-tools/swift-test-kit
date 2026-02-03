//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
import Foundation
@testable import XCTestKit
@testable import TKTestSupport



internal final class ComparatorMiscTests: XCTestKitCase
{
    // MARK: - Primitive types
    
    func testBooleanEqualValues() throws
    {
        let exp: Bool = true
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testBooleanDifferentValues() throws
    {
        let exp : Bool  = true
        let act : Bool  = false
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testIntegerEqualValues() throws
    {
        let exp: Int = 10
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testIntegerDifferentValues() throws
    {
        let exp : Int   = 10
        let act : Int   = 20
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testFloatEqualValues() throws
    {
        let exp: Float64 = 10 / 3
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testFloatDifferentValues() throws
    {
        let exp : Float64   = 10 / 3
        let act : Float64   = 20 / 3
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testStringEqualValues() throws
    {
        let exp: String = "hello"
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testStringDifferentValues() throws
    {
        let exp : String    = "hello"
        let act : String    = "goodbye"
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .character(index: 0, count: 4),
                    expected:   "hell",
                    actual:     "g"
                ),
                
                .makeUnexpected(
                    label:      .character(index: 5, count: 5),
                    actual:     "odbye"
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
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
        
        let exp     = User(name: "Someone", age: 30)
        let act     = User(name: "Someone", age: 20)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
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
        
        XCTKAssertEqual(expected, actual)
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
        
        let exp = Handler(
            id:         1,
            name:       "a",
            action:     { return 2 + 2 }
        )
        
        let act = Handler(
            id:         1,
            name:       "b",
            action:     { return 3 * 3 }
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "name"),
                    expected:   exp.name,
                    actual:     act.name,
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   exp.name,
                            actual:     act.name
                        )
                    ]
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Standard library types
    
    func testDataEqualValues() throws
    {
        let exp = Data([0x00, 0x01, 0x02, 0x03])
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testDataDifferentValues() throws
    {
        let expBytes    : [UInt8]   = [0x00, 0x01, 0x02, 0x03]
        let actBytes    : [UInt8]   = [0x00, 0x01, 0xFF, 0x03]
        let exp         : Data      = .init(expBytes)
        let act         : Data      = .init(actBytes)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "bytes"),
                    expected:   expBytes,
                    actual:     actBytes,
                    tree:
                    [
                        .makeLeaf(
                            label:      .index(2),
                            expected:   expBytes[2],
                            actual:     actBytes[2]
                        )
                    ]
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testDataDifferentLengths() throws
    {
        let expBytes    : [UInt8]   = [0x00, 0x01, 0x02]
        let actBytes    : [UInt8]   = [0x00, 0x01]
        let exp         : Data      = .init(expBytes)
        let act         : Data      = .init(actBytes)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "count"),
                    expected:   exp.count,
                    actual:     act.count
                ),
                
                .makeStructural(
                    label:      .property(name: "bytes"),
                    expected:   expBytes,
                    actual:     actBytes,
                    tree:
                    [
                        .makeMissing(
                            label:      .index(2),
                            expected:   expBytes[2]
                        )
                    ]
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testDateEqualValues() throws
    {
        let exp = Date(timeIntervalSince1970: 1_000_000)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testDateDifferentValues() throws
    {
        let exp     = Date(timeIntervalSince1970: 1_000_000)
        let act     = Date(timeIntervalSince1970: 2_000_000)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(
                                    name: "timeIntervalSinceReferenceDate"
                                ),
                    expected:   exp.timeIntervalSinceReferenceDate,
                    actual:     act.timeIntervalSinceReferenceDate
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
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
        
        let exp: Permissions = [.read, .write]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
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
        
        let exp : Permissions   = [.read, .write]
        let act : Permissions   = [.read, .execute]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "rawValue"),
                    expected:   exp.rawValue,
                    actual:     act.rawValue
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testRangeEqualValues() throws
    {
        let exp: Range<Int> = 0..<10
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testRangeDifferentValues() throws
    {
        let exp : Range<Int>    = 0..<10
        let act : Range<Int>    = 0..<5
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "upperBound"),
                    expected:   exp.upperBound,
                    actual:     act.upperBound
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testClosedRangeDifferentValues() throws
    {
        let exp : ClosedRange<Int>  = 0...10
        let act : ClosedRange<Int>  = 5...10
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "lowerBound"),
                    expected:   exp.lowerBound,
                    actual:     act.lowerBound
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testURLEqualValues() throws
    {
        let exp = URL(string: "https://example.com/page")!
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testUUIDEqualValues() throws
    {
        let exp = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testUUIDDifferentValues() throws
    {
        let exp     = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let act     = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Big data
    
    func testLargeArraySingleDifference() throws
    {
        let exp : [Int]     = Array(0..<10_000)
        var act : [Int]     = Array(0..<10_000)
        
        act[5000] = -1
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .index(5000),
                    expected:   exp[5000],
                    actual:     act[5000]
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testLargeArrayManyDifferences() throws
    {
        let exp : [Int]     = Array(0..<10_000)
        var act : [Int]     = Array(0..<10_000)
        
        for i in stride(from: 0, to: 10_000, by: 100)
        {
            act[i] = -1
        }
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       stride(from: 0, to: 10_000, by: 100).map
            {
                i in
                
                .makeLeaf(
                    label:      .index(i),
                    expected:   exp[i],
                    actual:     act[i]
                )
            }
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testLargeDictionarySingleDifference() throws
    {
        var exp : [Int : Int]   = [:]
        var act : [Int : Int]   = [:]
        
        for i in 0..<10_000
        {
            exp[i]  = i
            act[i]  = i
        }
        
        act[5000] = -1
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .key("5000", typeName: "Int"),
                    expected:   5000,
                    actual:     -1
                )
            ]
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testLargeSetManyDifferences() throws
    {
        let exp : Set<Int>  = .init(0..<10_000)
        let act : Set<Int>  = .init(500..<10_500)
        
        let missingNodes: [DiffNode] = (0..<500).map
        {
            return .makeMissing(
                label:      .member,
                expected:   $0
            )
        }
        
        let unexpectedNodes: [DiffNode] = (10_000..<10_500).map
        {
            return .makeUnexpected(
                label:      .member,
                actual:     $0
            )
        }
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       (missingNodes + unexpectedNodes).sorted
            {
                let lhs : String
                let rhs : String
                
                switch $0.kind
                {
                    case let .missing(exp)      : lhs = String(describing: exp)
                    case let .unexpected(act)   : lhs = String(describing: act)
                    default                     : lhs = ""
                }
                
                switch $1.kind
                {
                    case let .missing(exp)      : rhs = String(describing: exp)
                    case let .unexpected(act)   : rhs = String(describing: act)
                    default                     : rhs = ""
                }
                
                return lhs < rhs
            }
        )
        
        XCTKAssertEqual(expected, actual)
    }
}
