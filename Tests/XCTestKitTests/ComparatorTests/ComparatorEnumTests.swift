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



final class ComparatorEnumTests: XCTestKitCase
{
    func testEnumDifferentCases() throws
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
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumSameCaseEqualValues() throws
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        let exp: Status = .success(data: "hello")
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumSameCaseDifferentValues() throws
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
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumWithoutAssocDifferentCases() throws
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
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumWithoutAssocSameCase() throws
    {
        enum State: Equatable
        {
            case loading
            case ready
        }
        
        let exp: State = .loading
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMixedCaseWithAssocVsWithout() throws
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
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMixedCaseWithoutAssocVsWith() throws
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
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMultipleAssocSomeDifferent() throws
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        let exp : Result    = .success(a: 1, b: "x", c: 2)
        let act : Result    = .success(a: 1, b: "y", c: 2)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumMultipleAssocAllDifferent() throws
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        let exp : Result    = .success(a: 1, b: "x", c: 2)
        let act : Result    = .success(a: 3, b: "y", c: 4)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumUnlabeledAssoc() throws
    {
        enum Wrapper: Equatable
        {
            case pair(Int, Int)
        }
        
        let exp : Wrapper   = .pair(1, 2)
        let act : Wrapper   = .pair(1, 4)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumSingleUnlabeledAssoc() throws
    {
        enum Wrapper: Equatable
        {
            case value(Int)
        }
        
        let exp : Wrapper   = .value(1)
        let act : Wrapper   = .value(2)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumRawValueDifferentCases() throws
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
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testEnumRawValueSameCase() throws
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
            actual:     exp
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testResultSuccessEqualValues() throws
    {
        enum TestError: Error, Equatable
        {
            case failed
        }
        
        let exp: Result<String, TestError> = .success("hello")
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testResultSuccessDifferentValues() throws
    {
        enum TestError: Error, Equatable
        {
            case failed
        }
        
        let exp : Result<String, TestError>     = .success("hello")
        let act : Result<String, TestError>     = .success("goodbye")
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testResultSuccessVsFailure() throws
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
            actual:     act
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTKAssertEqual(expected, actual)
    }
    
    
    
    func testResultFailureDifferentErrors() throws
    {
        enum TestError: Error, Equatable
        {
            case someError(Int)
        }
        
        let exp : Result<String, TestError> = .failure(.someError(404))
        let act : Result<String, TestError> = .failure(.someError(418))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act
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
        
        XCTKAssertEqual(expected, actual)
    }
}
