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
@testable import struct TestKitCore.InterceptedFailure



internal final class FailureInterceptorTests: TestKitCase
{
    // MARK: - Initialize
    
    func testInitialState()
    {
        let interceptor = FailureInterceptor()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
    }
    
    
    
    // MARK: - Record
    
    func testRecordedFailureProperties() throws
    {
        let interceptor = FailureInterceptor()
        
        let message : String        = "some error"
        let fileID  : StaticString  = "ID"
        let file    : StaticString  = "File.swift"
        let line    : UInt          = 100
        let column  : UInt          = 50
        
        interceptor.recordFailure(
            message:    message,
            fileID:     fileID,
            file:       file,
            line:       line,
            column:     column
        )
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        
        let failure: InterceptedFailure
            = try XCTUnwrap(interceptor.failures.first)
        
        XCTAssertEqual(failure.message, message)
        XCTAssertEqual(failure.fileID.description, fileID.description)
        XCTAssertEqual(failure.file.description, file.description)
        XCTAssertEqual(failure.line, line)
        XCTAssertEqual(failure.column, column)
    }
    
    
    
    func testMultipleRecordingsPreservesOrder()
    {
        let interceptor = FailureInterceptor()
        
        let records: [(String, StaticString, StaticString, UInt, UInt)] =
        [
            ("Message1", "ID1", "1.swift", 1, 10),
            ("Message2", "ID2", "2.swift", 2, 20),
            ("Message3", "ID3", "3.swift", 3, 30)
        ]
        
        for record in records
        {
            interceptor.recordFailure(
                message:    record.0,
                fileID:     record.1,
                file:       record.2,
                line:       record.3,
                column:     record.4
            )
        }
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, records.count)
        
        for (i, failure) in interceptor.failures.enumerated()
        {
            XCTAssertEqual(failure.message, records[i].0)
            XCTAssertEqual(failure.fileID.description, records[i].1.description)
            XCTAssertEqual(failure.file.description, records[i].2.description)
            XCTAssertEqual(failure.line, records[i].3)
            XCTAssertEqual(failure.column, records[i].4)
        }
    }
    
    
    
    func testEmptyMessageRecording() throws
    {
        let interceptor = FailureInterceptor()
        
        let message : String        = ""
        let fileID  : StaticString  = "ID"
        let file    : StaticString  = "File.swift"
        let line    : UInt          = 100
        let column  : UInt          = 50
        
        interceptor.recordFailure(
            message:    message,
            fileID:     fileID,
            file:       file,
            line:       line,
            column:     column
        )
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        
        let failure: InterceptedFailure
            = try XCTUnwrap(interceptor.failures.first)
        
        XCTAssertEqual(failure.message, message)
        XCTAssertEqual(failure.fileID.description, fileID.description)
        XCTAssertEqual(failure.file.description, file.description)
        XCTAssertEqual(failure.line, line)
        XCTAssertEqual(failure.column, column)
    }
    
    
    
    // MARK: - Reset
    
    func testResetNewInstance()
    {
        let interceptor = FailureInterceptor()
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
    }
    
    
    
    func testRecordAfterReset()
    {
        let interceptor = FailureInterceptor()
        
        let records: [(String, StaticString, StaticString, UInt, UInt)] =
        [
            ("Message1", "ID1", "1.swift", 1, 10),
            ("Message2", "ID2", "2.swift", 2, 20),
            ("Message3", "ID3", "3.swift", 3, 30)
        ]
        
        for record in records
        {
            interceptor.recordFailure(
                message:    record.0,
                fileID:     record.1,
                file:       record.2,
                line:       record.3,
                column:     record.4
            )
        }
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, records.count)
        
        interceptor.reset()
        
        for record in records
        {
            interceptor.recordFailure(
                message:    record.0,
                fileID:     record.1,
                file:       record.2,
                line:       record.3,
                column:     record.4
            )
        }
        
        for (i, failure) in interceptor.failures.enumerated()
        {
            XCTAssertEqual(failure.message, records[i].0)
            XCTAssertEqual(failure.fileID.description, records[i].1.description)
            XCTAssertEqual(failure.file.description, records[i].2.description)
            XCTAssertEqual(failure.line, records[i].3)
            XCTAssertEqual(failure.column, records[i].4)
        }
    }
    
    
    
    func testRepeatedResetCycles()
    {
        let interceptor = FailureInterceptor()
        
        for index in 1...3
        {
            let message: String = "failure \(index)"
            
            interceptor.recordFailure(
                message:    message,
                fileID:     "ID",
                file:       "File.swift",
                line:       UInt(index),
                column:     UInt(index)
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
        XCTAssertNil(FailureInterceptor.current)
    }
    
    
    
    func testCurrentIsAvailableInsideWithValue()
    {
        let interceptor = FailureInterceptor()
        
        FailureInterceptor.$current.withValue(interceptor)
        {
            XCTAssertNotNil(FailureInterceptor.current)
            XCTAssertIdentical(FailureInterceptor.current, interceptor)
        }
    }
    
    
    
    func testCurrentIsRestoredAfterWithValue()
    {
        let interceptor = FailureInterceptor()
        
        FailureInterceptor.$current.withValue(interceptor)
        {
            XCTAssertNotNil(FailureInterceptor.current)
        }
        
        XCTAssertNil(FailureInterceptor.current)
    }
    
    
    
    func testNestedWithValueOverridesAndRestores()
    {
        let outer   = FailureInterceptor()
        let inner   = FailureInterceptor()
        
        FailureInterceptor.$current.withValue(outer)
        {
            XCTAssertIdentical(FailureInterceptor.current, outer)
            XCTAssertNotIdentical(FailureInterceptor.current, inner)
            
            FailureInterceptor.$current.withValue(inner)
            {
                XCTAssertNotIdentical(FailureInterceptor.current, outer)
                XCTAssertIdentical(FailureInterceptor.current, inner)
            }
            
            XCTAssertIdentical(FailureInterceptor.current, outer)
            XCTAssertNotIdentical(FailureInterceptor.current, inner)
        }
        
        XCTAssertNil(FailureInterceptor.current)
    }
    
    
    
    func testNestedInterceptorsAreIndependent()
    {
        let outer   = FailureInterceptor()
        let inner   = FailureInterceptor()
        
        let records: [(String, StaticString, StaticString, UInt, UInt)] =
        [
            ("Message1", "ID1", "1.swift", 1, 10),
            ("Message2", "ID2", "2.swift", 2, 20),
            ("Message3", "ID3", "3.swift", 3, 30)
        ]
        
        FailureInterceptor.$current.withValue(outer)
        {
            outer.recordFailure(
                message:    records[0].0,
                fileID:     records[0].1,
                file:       records[0].2,
                line:       records[0].3,
                column:     records[0].4
            )
            
            FailureInterceptor.$current.withValue(inner)
            {
                inner.recordFailure(
                    message:    records[1].0,
                    fileID:     records[1].1,
                    file:       records[1].2,
                    line:       records[1].3,
                    column:     records[1].4
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
            XCTAssertEqual(failure.fileID.description, records[0].1.description)
            XCTAssertEqual(failure.file.description, records[0].2.description)
            XCTAssertEqual(failure.line, records[0].3)
            XCTAssertEqual(failure.column, records[0].4)
        }
        
        for failure in inner.failures
        {
            XCTAssertEqual(failure.message, records[1].0)
            XCTAssertEqual(failure.fileID.description, records[1].1.description)
            XCTAssertEqual(failure.file.description, records[1].2.description)
            XCTAssertEqual(failure.line, records[1].3)
            XCTAssertEqual(failure.column, records[1].4)
        }
    }
    
    
    
    // MARK: - Concurrency
    
    func testConcurrentRecording() async throws
    {
        let interceptor : FailureInterceptor   = .init()
        let iterations  : Int                   = 1000
        
        await withTaskGroup(of: Void.self)
        {
            group in
            
            for index in 0..<iterations
            {
                interceptor.recordFailure(
                    message:    "failure \(index)",
                    fileID:     "ID",
                    file:       "File.swift",
                    line:       UInt(index),
                    column:     UInt(index)
                    
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
        let interceptorA    = FailureInterceptor()
        let interceptorB    = FailureInterceptor()
        
        async let taskA: Void
            = FailureInterceptor.$current.withValue(interceptorA)
        {
            XCTAssertIdentical(FailureInterceptor.current, interceptorA)
            XCTAssertNotIdentical(FailureInterceptor.current, interceptorB)
            
            interceptorA.recordFailure(
                message:    "Task A",
                fileID:     "ID-A",
                file:       "A.swift",
                line:       1,
                column:     2
            )
        }
        
        async let taskB: Void
            = FailureInterceptor.$current.withValue(interceptorB)
        {
            XCTAssertNotIdentical(FailureInterceptor.current, interceptorA)
            XCTAssertIdentical(FailureInterceptor.current, interceptorB)
            
            interceptorB.recordFailure(
                message:    "Task B",
                fileID:     "ID-B",
                file:       "B.swift",
                line:       2,
                column:     3
            )
        }
        
        _ = await (taskA, taskB)
        
        XCTAssertTrue(interceptorA.didFail)
        XCTAssertEqual(interceptorA.failures.count, 1)
        
        for failure in interceptorA.failures
        {
            XCTAssertEqual(failure.message, "Task A")
            XCTAssertEqual(failure.fileID.description, "ID-A")
            XCTAssertEqual(failure.file.description, "A.swift")
            XCTAssertEqual(failure.line, 1)
            XCTAssertEqual(failure.column, 2)
        }
        
        for failure in interceptorB.failures
        {
            XCTAssertEqual(failure.message, "Task B")
            XCTAssertEqual(failure.fileID.description, "ID-B")
            XCTAssertEqual(failure.file.description, "B.swift")
            XCTAssertEqual(failure.line, 2)
            XCTAssertEqual(failure.column, 3)
        }
    }
}
