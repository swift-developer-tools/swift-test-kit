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
    }
    
    
    
    // MARK: - Record
    
    func testRecordedFailureProperties() throws
    {
        let interceptor = PropertyInterceptor()
        
        let message : String        = "some error"
        let file    : StaticString  = "File.swift"
        let line    : UInt          = 100
        
        interceptor.record(
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
            interceptor.record(
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
        
        interceptor.record(
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
    
    func testResetClearsFailures()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.record(
            message:    "some error",
            file:       "File.swift",
            line:       100
        )
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
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
            interceptor.record(
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
            interceptor.record(
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
            
            interceptor.record(
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
            outer.record(
                message:    records[0].0,
                file:       records[0].1,
                line:       records[0].2
            )
            
            PropertyInterceptor.$current.withValue(inner)
            {
                inner.record(
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
                interceptor.record(
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
            
            interceptorA.record(
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
            
            interceptorB.record(
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
