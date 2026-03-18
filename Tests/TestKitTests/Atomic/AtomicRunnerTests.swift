//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class AtomicRunnerTests: TestKitCase
{
    private typealias FailedValues = FailedAtomicValues
    
    
    
    // MARK: - Passing
    
    @Reasync
    func testPassesWithEmptyBody() async
    {
        let body: () async throws -> Void = { }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        result.assertPassed()
    }
    
    
    
    @Reasync
    func testPassesWhenBodyExecutesWithoutFailures() async
    {
        var executed: Bool = false
        
        let body: () async throws -> Void = { executed = true }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        result.assertPassed()
        XCTAssertTrue(executed)
    }
    
    
    
    // MARK: - Failing (assertions)
    
    @Reasync
    func testFailsWithOneAssertion() async throws
    {
        let body: () async throws -> Void =
        {
            FailureInterceptor.current?.recordFailure(
                message:    "first",
                fileID:     "ID1",
                file:       "File1.swift",
                line:       1,
                column:     2
            )
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[0].fileID.description, "ID1")
        XCTAssertEqual(failed.failures[0].file.description, "File1.swift")
        XCTAssertEqual(failed.failures[0].line, 1)
        XCTAssertEqual(failed.failures[0].column, 2)
        XCTAssertNil(failed.error)
    }
    
    
    
    @Reasync
    func testFailsWithMultipleAssertions() async throws
    {
        let body: () async throws -> Void =
        {
            FailureInterceptor.current?.recordFailure(
                message:    "first",
                fileID:     "ID1",
                file:       "File1.swift",
                line:       1,
                column:     2
            )
            
            FailureInterceptor.current?.recordFailure(
                message:    "second",
                fileID:     "ID2",
                file:       "File2.swift",
                line:       3,
                column:     4
            )
            
            FailureInterceptor.current?.recordFailure(
                message:    "third",
                fileID:     "ID3",
                file:       "File3.swift",
                line:       5,
                column:     6
            )
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 3)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
        XCTAssertEqual(failed.failures[2].message, "third")
        XCTAssertNil(failed.error)
    }
    
    
    
    // MARK: - Failing (errors)
    
    @Reasync
    func testFailsWithThrownErrorOnly() async throws
    {
        let body: () async throws -> Void =
        {
            throw TestError()
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.failures.isEmpty)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    @Reasync
    func testFailsWithAssertionsAndThrownError() async throws
    {
        let body: () async throws -> Void =
        {
            FailureInterceptor.current?.recordFailure(
                message:    "first",
                fileID:     "ID1",
                file:       "File1.swift",
                line:       1,
                column:     2
            )
            
            throw TestError()
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[0].fileID.description, "ID1")
        XCTAssertEqual(failed.failures[0].file.description, "File1.swift")
        XCTAssertEqual(failed.failures[0].line, 1)
        XCTAssertEqual(failed.failures[0].column, 2)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    @Reasync
    func testErrorTypePreserved() async throws
    {
        let expected = IdentifiableTestError(id: 50)
        
        let body: () async throws -> Void =
        {
            throw expected
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        let actual: IdentifiableTestError
            = try XCTUnwrap(failed.error as? IdentifiableTestError)
        
        XCTAssertEqual(expected.id, actual.id)
    }
    
    
    
    // MARK: - Visibility
    
    @Reasync
    func testBodySeesAtomicInterceptor() async throws
    {
        let outer = FailureInterceptor()
        
        let body: () async throws -> Void =
        {
            /// Inside the body, the current interceptor must be the
            /// atomic interceptor, not the outer one.
            XCTAssertNotNil(FailureInterceptor.current)
            XCTAssertNotIdentical(FailureInterceptor.current, outer)
            XCTAssertTrue(FailureInterceptor.current is AtomicInterceptor)
        }
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await AtomicRunner.run(body: body)
        }
    }
    
    
    
    // MARK: - Nested
    
    @Reasync
    func testNestedDoesNotLeak() async
    {
        let outer = FailureInterceptor()
        
        let body: () async throws -> Void =
        {
            FailureInterceptor.current?.recordFailure()
        }
        
        await FailureInterceptor.$current.withValue(outer)
        {
            let result: AtomicResult = await AtomicRunner.run(body: body)
            
            result.assertFailed()
        }
        
        XCTAssertFalse(outer.didFail)
        XCTAssertTrue(outer.failures.isEmpty)
    }
    
    
    
    @Reasync
    func testOuterInterceptorRestored() async
    {
        let outer = FailureInterceptor()
        
        let body: () async throws -> Void = { }
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await AtomicRunner.run(body: body)
            
            XCTAssertIdentical(FailureInterceptor.current, outer)
        }
    }
    
    
    
    @Reasync
    func testNestedRunnersIdempotency() async
    {
        let innerBody: () async throws -> Void =
        {
            FailureInterceptor.current?.recordFailure()
        }
        
        let outerBody: () async throws -> Void =
        {
            let result: AtomicResult = await AtomicRunner.run(body: innerBody)
            
            result.assertFailed()
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: outerBody)
        
        result.assertPassed()
    }
    
    
    
    @Reasync
    func testInnerFailurePropagatedToOuter() async throws
    {
        let innerBody: () async throws -> Void =
        {
            FailureInterceptor.current?.recordFailure(
                message:    "inner",
                fileID:     "ID",
                file:       "File.swift",
                line:       1,
                column:     2
            )
        }
        
        let outerBody: () async throws -> Void =
        {
            let innerResult: AtomicResult = await AtomicRunner.run(body: innerBody)
            
            if case .failed = innerResult
            {
                FailureInterceptor.current?.recordFailure(
                    message:    "propagated",
                    fileID:     "ID",
                    file:       "File.swift",
                    line:       1,
                    column:     2
                )
            }
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: outerBody)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertEqual(failed.failures[0].message, "propagated")
    }
    
    
    
    // MARK: - Execution
    
    @Reasync
    func testBodyExecutesExactlyOnce() async
    {
        var count: Int = 0
        
        let body: () async throws -> Void =
        {
            count += 1
        }
        
        _ = await AtomicRunner.run(body: body)
        
        XCTAssertEqual(count, 1)
    }
    
    
    
    @Reasync
    func testOnlyFailuresRecorded() async throws
    {
        var sideEffects: [String] = []
        
        let body: () async throws -> Void =
        {
            sideEffects.append("a")
            
            FailureInterceptor.current?.recordFailure(
                message:    "first",
                fileID:     "ID1",
                file:       "File1.swift",
                line:       1,
                column:     2
            )
            
            sideEffects.append("b")
            sideEffects.append("c")
            
            FailureInterceptor.current?.recordFailure(
                message:    "second",
                fileID:     "ID2",
                file:       "File2.swift",
                line:       3,
                column:     4
            )
            
            sideEffects.append("d")
        }
        
        let result: AtomicResult = await AtomicRunner.run(body: body)
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 2)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
        XCTAssertEqual(sideEffects, ["a", "b", "c", "d"])
    }
}
