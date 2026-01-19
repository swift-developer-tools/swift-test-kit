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
        
        
        
        let expected    : Status    = .success(data: "hello")
        let actual      : Status    = .failure(error: "goodbye", code: 418)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Status, expected)
        XCTAssertEqual(act.value as? Status, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumSameCaseEqualValues() throws
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        
        
        let expected: Status = .success(data: "hello")
        
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
    
    
    
    func testEnumSameCaseDifferentValues() throws
    {
        enum Status: Equatable
        {
            case success(data: String)
            case failure(error: String)
        }
        
        
        
        let expected    : Status    = .success(data: "hello")
        let actual      : Status    = .success(data: "goodbye")
        
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
        XCTAssertEqual(tree[0].label, .property(name: "data"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "hello")
        XCTAssertEqual(act.value as? String, "goodbye")
    }
    
    
    
    func testEnumWithoutAssocDifferentCases() throws
    {
        enum State: Equatable
        {
            case loading
            case ready
            case error
        }
        
        
        
        let expected    : State     = .loading
        let actual      : State     = .error
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? State, expected)
        XCTAssertEqual(act.value as? State, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumWithoutAssocSameCase() throws
    {
        enum State: Equatable
        {
            case loading
            case ready
        }
        
        
        
        let expected: State = .loading
        
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
    
    
    
    func testEnumMixedCaseWithAssocVsWithout() throws
    {
        enum State: Equatable
        {
            case loading
            case loaded(data: String)
        }
        
        
        
        let expected    : State     = .loaded(data: "hello")
        let actual      : State     = .loading
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? State, expected)
        XCTAssertEqual(act.value as? State, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumMixedCaseWithoutAssocVsWith() throws
    {
        enum State: Equatable
        {
            case loading
            case loaded(data: String)
        }
        
        
        
        let expected    : State     = .loading
        let actual      : State     = .loaded(data: "hello")
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? State, expected)
        XCTAssertEqual(act.value as? State, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumMultipleAssocSomeDifferent() throws
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        
        
        let expected    : Result    = .success(a: 1, b: "x", c: 2)
        let actual      : Result    = .success(a: 1, b: "y", c: 2)
        
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
        XCTAssertEqual(tree[0].label, .property(name: "b"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "x")
        XCTAssertEqual(act.value as? String, "y")
    }
    
    
    
    func testEnumMultipleAssocAllDifferent() throws
    {
        enum Result: Equatable
        {
            case success(a: Int, b: String, c: Int)
        }
        
        
        
        let expected    : Result    = .success(a: 1, b: "x", c: 2)
        let actual      : Result    = .success(a: 3, b: "y", c: 4)
        
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
        
        XCTAssertEqual(tree.count, 3)
        XCTAssertEqual(tree[0].label, .property(name: "a"))
        XCTAssertEqual(tree[1].label, .property(name: "b"))
        XCTAssertEqual(tree[2].label, .property(name: "c"))
    }
    
    
    
    func testEnumUnlabeledAssoc() throws
    {
        enum Wrapper: Equatable
        {
            case pair(Int, Int)
        }
        
        
        
        let expected    : Wrapper    = .pair(1, 2)
        let actual      : Wrapper    = .pair(1, 4)
        
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
        XCTAssertEqual(tree[0].label, .property(name: ".1"))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 2)
        XCTAssertEqual(act.value as? Int, 4)
    }
    
    
    
    func testEnumSingleUnlabeledAssoc() throws
    {
        enum Wrapper: Equatable
        {
            case value(Int)
        }
        
        
        
        let expected    : Wrapper    = .value(1)
        let actual      : Wrapper    = .value(2)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp1, act1, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp1.value as? Wrapper, expected)
        XCTAssertEqual(act1.value as? Wrapper, actual)
        XCTAssertEqual(tree.count, 1)
        XCTAssertEqual(tree[0].label, .index(0))
        
        
        
        guard case let .different(exp2, act2, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp2.value as? Int, 1)
        XCTAssertEqual(act2.value as? Int, 2)
    }
    
    
    
    func testEnumRawValueDifferentCases() throws
    {
        enum Priority: Int, Equatable
        {
            case low        = 1
            case medium     = 2
            case high       = 3
        }
        
        
        
        let expected    : Priority  = .low
        let actual      : Priority  = .high
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Priority, expected)
        XCTAssertEqual(act.value as? Priority, actual)
        XCTAssertTrue(tree.isEmpty)
    }
    
    
    
    func testEnumRawValueSameCase() throws
    {
        enum Priority: Int, Equatable
        {
            case low        = 1
            case medium     = 2
            case high       = 3
        }
        
        
        
        let expected: Priority = .low
        
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
    
    
    
    func testResultSuccessEqualValues() throws
    {
        enum TestError: Error, Equatable
        {
            case failed
        }
        
        
        
        let expected: Result<String, TestError> = .success("hello")
        
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
    
    
    
    func testResultSuccessDifferentValues() throws
    {
        enum TestError: Error, Equatable
        {
            case failed
        }
        
        
        
        let expected    : Result<String, TestError>     = .success("hello")
        let actual      : Result<String, TestError>     = .success("goodbye")
        
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
        XCTAssertEqual(tree[0].label, .index(0))
        
        
        
        guard case let .different(exp, act, _) = tree[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? String, "hello")
        XCTAssertEqual(act.value as? String, "goodbye")
    }
    
    
    
    func testResultSuccessVsFailure() throws
    {
        enum TestError: Error, Equatable
        {
            case errorA
            case errorB
        }
        
        
        
        let expected    : Result<String, TestError>     = .success("data")
        let actual      : Result<String, TestError>     = .failure(.errorA)
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(exp, act, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertTrue(tree.isEmpty)
        
        
        
        guard
            case .success(let expValue)
                = exp.value as? Result<String, TestError>,
            
            case .failure(let actValue)
                = act.value as? Result<String, TestError>
        else
        {
            XCTFail("Unexpected types in diff")
            return
        }
        
        XCTAssertEqual(expValue, "data")
        XCTAssertEqual(actValue, .errorA)
    }
    
    
    
    func testResultFailureDifferentErrors() throws
    {
        enum TestError: Error, Equatable
        {
            case someError(code: Int)
        }
        
        
        
        let expected: Result<String, TestError>
            = .failure(.someError(code: 404))
        
        let actual: Result<String, TestError>
            = .failure(.someError(code: 418))
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "someError"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "code"))
        
        
        
        guard case let .different(exp, act, _) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 404)
        XCTAssertEqual(act.value as? Int, 418)
    }
}
