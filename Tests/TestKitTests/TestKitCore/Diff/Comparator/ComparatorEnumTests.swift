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



internal final class ComparatorEnumTests: TestKitCase
{
    func testEnumDifferentCases()
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String, code: Int)
        }
        
        let exp : Status    = .success(data: "hello")
        let act : Status    = .failure(error: "goodbye", code: 418)
        
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumSameCaseEqualValues()
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        let exp: Status = .success(data: "hello")
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumSameCaseDifferentValues()
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        let exp : Status    = .success(data: "hello")
        let act : Status    = .success(data: "goodbye")
        
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
                    label:      .property(name: "data"),
                    expected:   "hello",
                    actual:     "goodbye",
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
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumWithoutAssocDifferentCases()
    {
        enum State: Equatable
        {
            case loading
            case ready
            case error
        }
        
        let exp : State     = .loading
        let act : State     = .error
        
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumWithoutAssocSameCase()
    {
        enum State: Equatable
        {
            case loading
            case ready
        }
        
        let exp: State = .loading
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMixedCaseWithAssocVsWithout()
    {
        enum State: Equatable
        {
            case loading
            case loaded(data: String)
        }
        
        let exp : State     = .loaded(data: "hello")
        let act : State     = .loading
        
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMixedCaseWithoutAssocVsWith()
    {
        enum State: Equatable
        {
            case loading
            case loaded(data: String)
        }
        
        let exp : State     = .loading
        let act : State     = .loaded(data: "hello")
        
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMultipleAssocSomeDifferent()
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        let exp : Result    = .success(a: 1, b: "x", c: 2)
        let act : Result    = .success(a: 1, b: "y", c: 2)
        
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
                    label:      .property(name: "b"),
                    expected:   "x",
                    actual:     "y",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   "x",
                            actual:     "y"
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMultipleAssocAllDifferent()
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        let exp : Result    = .success(a: 1, b: "x", c: 2)
        let act : Result    = .success(a: 3, b: "y", c: 4)
        
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
                    label:      .property(name: "a"),
                    expected:   1,
                    actual:     3
                ),
                
                .makeStructural(
                    label:      .property(name: "b"),
                    expected:   "x",
                    actual:     "y",
                    tree:
                    [
                        .makeLeaf(
                            label:      .character(index: 0, count: 1),
                            expected:   "x",
                            actual:     "y"
                        )
                    ]
                ),
                
                .makeLeaf(
                    label:      .property(name: "c"),
                    expected:   2,
                    actual:     4
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumUnlabeledAssoc()
    {
        enum Wrapper: Equatable
        {
            case pair(Int, Int)
        }
        
        let exp : Wrapper   = .pair(1, 2)
        let act : Wrapper   = .pair(1, 4)
        
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
                    label:      .property(name: ".1"),
                    expected:   2,
                    actual:     4
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumSingleUnlabeledAssoc()
    {
        enum Wrapper: Equatable
        {
            case value(Int)
        }
        
        let exp : Wrapper   = .value(1)
        let act : Wrapper   = .value(2)
        
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
                    label:      .index(0),
                    expected:   1,
                    actual:     2
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumRawValueDifferentCases()
    {
        enum Priority: Int, Equatable
        {
            case low        = 1
            case medium     = 2
            case high       = 3
        }
        
        let exp : Priority  = .low
        let act : Priority  = .high
        
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEnumRawValueSameCase()
    {
        enum Priority: Int, Equatable
        {
            case low        = 1
            case medium     = 2
            case high       = 3
        }
        
        let exp: Priority = .low
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testResultSuccessEqualValues()
    {
        enum TestError: Error, Equatable
        {
            case failed
        }
        
        let exp: Result<String, TestError> = .success("hello")
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testResultSuccessDifferentValues()
    {
        enum TestError: Error, Equatable
        {
            case failed
        }
        
        let exp : Result<String, TestError>     = .success("hello")
        let act : Result<String, TestError>     = .success("goodbye")
        
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
                    label:      .index(0),
                    expected:   "hello",
                    actual:     "goodbye",
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
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testResultSuccessVsFailure()
    {
        enum TestError: Error, Equatable
        {
            case errorA
            case errorB
        }
        
        let exp : Result<String, TestError>     = .success("data")
        let act : Result<String, TestError>     = .failure(.errorA)
        
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
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testResultFailureDifferentErrors()
    {
        enum TestError: Error, Equatable
        {
            case someError(Int)
        }
        
        let exp : Result<String, TestError> = .failure(.someError(404))
        let act : Result<String, TestError> = .failure(.someError(418))
        
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
                    label:      .property(name: "someError"),
                    expected:   404,
                    actual:     418
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}
