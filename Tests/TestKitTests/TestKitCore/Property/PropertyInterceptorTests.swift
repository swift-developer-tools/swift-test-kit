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



internal final class PropertyInterceptorTests: XCTestCaseStopOnFail
{
    // MARK: - Initialize
    
    func testInitialState()
    {
        let interceptor = PropertyInterceptor()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertTrue(interceptor.distribution.isEmpty)
        XCTAssertTrue(interceptor.coverageRequirements.isEmpty)
    }
    
    
    
    // MARK: - Record
    
    func testRecordedFailureProperties() throws
    {
        let interceptor = PropertyInterceptor()
        
        let message : String        = "some error"
        let file    : StaticString  = "File.swift"
        let line    : UInt          = 100
        
        interceptor.recordFailure(
            message:    message,
            file:       file,
            line:       line
        )
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        
        let failure: InterceptedFailure
            = try XCTUnwrap(interceptor.failures.first)
        
        XCTAssertEqual(failure.message, message)
        XCTAssertEqual(failure.file.description, file.description)
        XCTAssertEqual(failure.line, line)
    }
    
    
    
    func testMultipleRecordingsPreservesOrder()
    {
        let interceptor = PropertyInterceptor()
        
        let records: [(String, StaticString, UInt)] =
        [
            ("first", "A.swift", 1),
            ("second", "B.swift", 2),
            ("third", "C.swift", 3)
        ]
        
        for record in records
        {
            interceptor.recordFailure(
                message:    record.0,
                file:       record.1,
                line:       record.2
            )
        }
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, records.count)
        
        for (i, failure) in interceptor.failures.enumerated()
        {
            XCTAssertEqual(failure.message, records[i].0)
            XCTAssertEqual(failure.file.description, records[i].1.description)
            XCTAssertEqual(failure.line, records[i].2)
        }
    }
    
    
    
    func testEmptyMessageRecording() throws
    {
        let interceptor = PropertyInterceptor()
        
        let message : String        = ""
        let file    : StaticString  = "File.swift"
        let line    : UInt          = 100
        
        interceptor.recordFailure(
            message:    message,
            file:       file,
            line:       line
        )
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        
        let failure: InterceptedFailure
            = try XCTUnwrap(interceptor.failures.first)
        
        XCTAssertEqual(failure.message, message)
        XCTAssertEqual(failure.file.description, file.description)
        XCTAssertEqual(failure.line, line)
    }
    
    
    
    // MARK: - Reset
    
    func testResetClearsFailuresAndLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordFailure(
            message:    "error",
            file:       "File.swift",
            line:       100
        )
        
        interceptor.recordLabel("label")
        interceptor.recordCoverageRequirement(50, for: "req")
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        XCTAssertEqual(interceptor.labels, ["label"])
        XCTAssertEqual(interceptor.coverageRequirements, ["req": 50])
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.coverageRequirements, ["req": 50])
    }
    
    
    
    func testResetPreservesDistributionAndCoverage()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(50, for: "a")
        
        interceptor.recordLabel("a")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("b")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("c")
        
        interceptor.recordFailure(
            message:    "error",
            file:       "File.swift",
            line:       100
        )
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 50])
        XCTAssertEqual(interceptor.distribution, ["a": 1, "b": 1])
    }
    
    
    
    func testResetNewInstance()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
    }
    
    
    
    func testRecordAfterReset()
    {
        let interceptor = PropertyInterceptor()
        
        let records: [(String, StaticString, UInt)] =
        [
            ("first", "A.swift", 1),
            ("second", "B.swift", 2),
            ("third", "C.swift", 3)
        ]
        
        for record in records
        {
            interceptor.recordFailure(
                message:    record.0,
                file:       record.1,
                line:       record.2
            )
        }
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, records.count)
        
        interceptor.reset()
        
        for record in records
        {
            interceptor.recordFailure(
                message:    record.0,
                file:       record.1,
                line:       record.2
            )
        }
        
        for (i, failure) in interceptor.failures.enumerated()
        {
            XCTAssertEqual(failure.message, records[i].0)
            XCTAssertEqual(failure.file.description, records[i].1.description)
            XCTAssertEqual(failure.line, records[i].2)
        }
    }
    
    
    
    func testRepeatedResetCycles()
    {
        let interceptor = PropertyInterceptor()
        
        for index in 1...3
        {
            let message: String = "failure \(index)"
            
            interceptor.recordFailure(
                message:    message,
                file:       "File.swift",
                line:       UInt(index)
            )
            
            XCTAssertTrue(interceptor.didFail)
            XCTAssertEqual(interceptor.failures.count, 1)
            XCTAssertEqual(interceptor.failures[0].message, message)
            
            interceptor.reset()
        }
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
    }
    
    
    
    // MARK: - Labels
    
    func testRecordLabelAddsToCurrentIteration()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        
        XCTAssertEqual(interceptor.labels, ["a"])
        XCTAssertTrue(interceptor.distribution.isEmpty)
    }
    
    
    
    func testRecordMultipleLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("b")
        interceptor.recordLabel("c")
        
        XCTAssertEqual(interceptor.labels, ["a", "b", "c"])
    }
    
    
    
    func testRecordDuplicateLabelIdempotency()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        
        XCTAssertEqual(interceptor.labels, ["a"])
    }
    
    
    
    // MARK: - Finalize iteration
    
    func testFinalizeIterationDuplicateLabelsIdempotency()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        interceptor.finalizeIteration()
        
        XCTAssertEqual(interceptor.distribution, ["a": 1])
    }
    
    
    
    func testFinalizeIterationFlushesLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("b")
        
        XCTAssertEqual(interceptor.labels, ["a", "b"])
        XCTAssertTrue(interceptor.distribution.isEmpty)
        
        interceptor.finalizeIteration()
        
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.distribution, ["a": 1, "b": 1])
    }
    
    
    
    func testFinalizeIterationAccumulatesAcrossIterations()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("b")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("c")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("b")
        interceptor.recordLabel("d")
        interceptor.finalizeIteration()
        
        XCTAssertEqual(
            interceptor.distribution,
            ["a": 2, "b": 2, "c": 1, "d": 1]
        )
    }
    
    
    
    func testFinalizeIterationWithNoLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.finalizeIteration()
        interceptor.finalizeIteration()
        interceptor.finalizeIteration()
        
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertTrue(interceptor.distribution.isEmpty)
    }
    
    
    
    // MARK: - Coverage requirements
    
    func testRecordCoverageReq()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 5])
    }
    
    
    
    func testRecordCoverageReqMaxOverrides()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        interceptor.recordCoverageRequirement(10, for: "a")
        interceptor.recordCoverageRequirement(2, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 10])
    }
    
    
    
    func testRecordCoverageReqMultipleLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        interceptor.recordCoverageRequirement(10, for: "b")
        interceptor.recordCoverageRequirement(2, for: "c")
        
        XCTAssertEqual(
            interceptor.coverageRequirements,
            ["a": 5, "b": 10, "c": 2]
        )
    }
    
    
    
    func testRecordCoverageReqClampsAbove()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(150, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 100])
    }
    
    
    
    func testRecordCoverageReqClampsBelow()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(-150, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 0])
    }
    
    
    
    // MARK: - Check coverage
    
    func testCheckCoverageReturnsEmptyWhenMet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(10, for: "a")
        
        for index in 0..<100
        {
            if index < 20
            {
                interceptor.recordLabel("a")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageReturnsUnmetReqs()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(50, for: "a")
        interceptor.recordCoverageRequirement(10, for: "b")
        
        for index in 0..<100
        {
            if index < 10
            {
                interceptor.recordLabel("a")
            }
            else if index < 40
            {
                interceptor.recordLabel("b")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 50)
        XCTAssertEqual(unmet[0].actual, 10)
        XCTAssertNil(unmet[0].table)
    }
    
    
    
    func testCheckCoverageWithZeroPercentageAlwaysMet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(0, for: "a")
        
        for _ in 0..<100
        {
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageExactlyAtThreshold()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(10, for: "a")
        
        for index in 0..<100
        {
            /// Exactly 10%.
            if index < 10
            {
                interceptor.recordLabel("a")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageWithNoReqs()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.finalizeIteration()
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 1)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageUnrecordedLabelWithReq()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        
        for _ in 0..<100
        {
            interceptor.recordLabel("b")
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 5)
        XCTAssertEqual(unmet[0].actual, 0)
        XCTAssertNil(unmet[0].table)
    }
    
    
    
    // MARK: - TaskLocal
    
    func testCurrentIsNilByDefault()
    {
        XCTAssertNil(PropertyInterceptor.current)
    }
    
    
    
    func testCurrentIsAvailableInsideWithValue()
    {
        let interceptor = PropertyInterceptor()
        
        PropertyInterceptor.$current.withValue(interceptor)
        {
            XCTAssertNotNil(PropertyInterceptor.current)
            XCTAssertIdentical(PropertyInterceptor.current, interceptor)
        }
    }
    
    
    
    func testCurrentIsRestoredAfterWithValue()
    {
        let interceptor = PropertyInterceptor()
        
        PropertyInterceptor.$current.withValue(interceptor)
        {
            XCTAssertNotNil(PropertyInterceptor.current)
        }
        
        XCTAssertNil(PropertyInterceptor.current)
    }
    
    
    
    func testNestedWithValueOverridesAndRestores()
    {
        let outer   = PropertyInterceptor()
        let inner   = PropertyInterceptor()
        
        PropertyInterceptor.$current.withValue(outer)
        {
            XCTAssertIdentical(PropertyInterceptor.current, outer)
            XCTAssertNotIdentical(PropertyInterceptor.current, inner)
            
            PropertyInterceptor.$current.withValue(inner)
            {
                XCTAssertNotIdentical(PropertyInterceptor.current, outer)
                XCTAssertIdentical(PropertyInterceptor.current, inner)
            }
            
            XCTAssertIdentical(PropertyInterceptor.current, outer)
            XCTAssertNotIdentical(PropertyInterceptor.current, inner)
        }
        
        XCTAssertNil(PropertyInterceptor.current)
    }
    
    
    
    func testNestedInterceptorsAreIndependent()
    {
        let outer   = PropertyInterceptor()
        let inner   = PropertyInterceptor()
        
        let records: [(String, StaticString, UInt)] =
        [
            ("first", "A.swift", 1),
            ("second", "B.swift", 2)
        ]
        
        PropertyInterceptor.$current.withValue(outer)
        {
            outer.recordFailure(
                message:    records[0].0,
                file:       records[0].1,
                line:       records[0].2
            )
            
            PropertyInterceptor.$current.withValue(inner)
            {
                inner.recordFailure(
                    message:    records[1].0,
                    file:       records[1].1,
                    line:       records[1].2
                )
            }
        }
        
        XCTAssertTrue(outer.didFail)
        XCTAssertTrue(inner.didFail)
        XCTAssertEqual(outer.failures.count, 1)
        XCTAssertEqual(inner.failures.count, 1)
        
        for failure in outer.failures
        {
            XCTAssertEqual(failure.message, records[0].0)
            XCTAssertEqual(failure.file.description, records[0].1.description)
            XCTAssertEqual(failure.line, records[0].2)
        }
        
        for failure in inner.failures
        {
            XCTAssertEqual(failure.message, records[1].0)
            XCTAssertEqual(failure.file.description, records[1].1.description)
            XCTAssertEqual(failure.line, records[1].2)
        }
    }
    
    
    
    // MARK: - Concurrency
    
    func testConcurrentRecording() async throws
    {
        let interceptor : PropertyInterceptor   = .init()
        let iterations  : Int                   = 1000
        
        await withTaskGroup(of: Void.self)
        {
            group in
            
            for index in 0..<iterations
            {
                interceptor.recordFailure(
                    message:    "failure \(index)",
                    file:       "File.swift",
                    line:       UInt(index)
                )
            }
        }
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, iterations)
        
        /// Check that no failures were lost or corrupted.
        let lines: Set<UInt> = Set(interceptor.failures.map(\.line))
        
        XCTAssertEqual(lines.count, iterations)
    }
    
    
    
    func testTaskLocalIsolationAcrossConcurrentTasks() async throws
    {
        let interceptorA    = PropertyInterceptor()
        let interceptorB    = PropertyInterceptor()
        
        async let taskA: Void
            = PropertyInterceptor.$current.withValue(interceptorA)
        {
            XCTAssertIdentical(PropertyInterceptor.current, interceptorA)
            XCTAssertNotIdentical(PropertyInterceptor.current, interceptorB)
            
            interceptorA.recordFailure(
                message:    "Task A",
                file:       "A.swift",
                line:       1
            )
        }
        
        async let taskB: Void
            = PropertyInterceptor.$current.withValue(interceptorB)
        {
            XCTAssertNotIdentical(PropertyInterceptor.current, interceptorA)
            XCTAssertIdentical(PropertyInterceptor.current, interceptorB)
            
            interceptorB.recordFailure(
                message:    "Task B",
                file:       "B.swift",
                line:       2
            )
        }
        
        _ = await (taskA, taskB)
        
        XCTAssertTrue(interceptorA.didFail)
        XCTAssertEqual(interceptorA.failures.count, 1)
        
        for failure in interceptorA.failures
        {
            XCTAssertEqual(failure.message, "Task A")
            XCTAssertEqual(failure.file.description, "A.swift")
            XCTAssertEqual(failure.line, 1)
        }
        
        for failure in interceptorB.failures
        {
            XCTAssertEqual(failure.message, "Task B")
            XCTAssertEqual(failure.file.description, "B.swift")
            XCTAssertEqual(failure.line, 2)
        }
    }
}
