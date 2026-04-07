//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import Synchronization
import XCTest



/// Test the right-alignment of performance evaluator output, since the main
/// output tests remove the non-deterministic values and alignment.
internal final class PerformanceAlignmentTests: TestKitCase
{
    func testWallTimeEqualWidth()
    {
        let result: PerformanceResult = .makeCompleted(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(50), count: 5),
            medianWallTime:     .milliseconds(50),
            wallTimeLimit:      .milliseconds(10)
        )
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Wall time:
            Threshold: 10 ms
            Median:    50 ms (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testWallTimeDifferentWidth()
    {
        let result: PerformanceResult = .makeCompleted(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(123), count: 5),
            medianWallTime:     .milliseconds(123),
            wallTimeLimit:      .milliseconds(50)
        )
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Wall time:
            Threshold:  50 ms
            Median:    123 ms (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMemoryDifferentWidth()
    {
        let result: PerformanceResult = .makeCompleted(
            runs:           3,
            memory:         Array(repeating: .kilobytes(512), count: 3),
            medianMemory:   .kilobytes(512),
            memoryLimit:    .kilobytes(1)
        )
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Memory:
            Threshold:   1 KB
            Median:    512 KB (3 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleMetricsOneExceeded()
    {
        let result: PerformanceResult = .makeCompleted(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(5), count: 5),
            medianWallTime:     .milliseconds(5),
            wallTimeLimit:      .milliseconds(500),
            memory:             Array(repeating: .megabytes(2.5), count: 5),
            medianMemory:       .megabytes(2.5),
            memoryLimit:        .megabytes(1)
        )
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Wall time:
            Threshold: 500 ms
            Median:      5 ms (5 runs)
        
        Memory:
            Threshold:   1 MB
            Median:    2.5 MB (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAllMetricsExceeded()
    {
        let result: PerformanceResult = .makeCompleted(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(123), count: 5),
            medianWallTime:     .milliseconds(123),
            wallTimeLimit:      .milliseconds(50),
            memory:             Array(repeating: .megabytes(2.5), count: 5),
            medianMemory:       .megabytes(2.5),
            memoryLimit:        .megabytes(1)
        )
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Wall time:
            Threshold:  50 ms
            Median:    123 ms (5 runs) ←
        
        Memory:
            Threshold:   1 MB
            Median:    2.5 MB (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Support

extension PerformanceAlignmentTests
{
    func emit(
        _ result: PerformanceResult
    ) -> String?
    {
        let captured = Mutex<String?>(nil)
        
        let context = FailureContext(framework: .xctk)
        {
            message, _, _, _, _ in
            
            captured.withLock { $0 = message }
        }
        
        result.emit(
            runs:           5,
            warmupRuns:     0,
            functionName:   "XCTKPerformance",
            options:        TestOptions(),
            context:        context,
            message:        { "" },
            fileID:         #fileID,
            file:           #file,
            line:           #line,
            column:         #column
        )
        
        return captured.withLock { $0 }
    }
}



private extension PerformanceResult
{
    /// Creates a ``PerformanceResult/completed(measurements:)`` instance from
    /// the given values.
    static func makeCompleted(
        runs           : Int,
        wallTime       : [Duration]?    = nil,
        medianWallTime : Duration?      = nil,
        wallTimeLimit  : Duration?      = nil,
        cpuTime        : [Duration]?    = nil,
        medianCPUTime  : Duration?      = nil,
        cpuTimeLimit   : Duration?      = nil,
        memory         : [ByteCount]?   = nil,
        medianMemory   : ByteCount?     = nil,
        memoryLimit    : ByteCount?     = nil
    ) -> PerformanceResult
    {
        return .completed(measurements: .init(
            runs:               runs,
            wallTime:           wallTime,
            medianWallTime:     medianWallTime,
            wallTimeLimit:      wallTimeLimit,
            cpuTime:            cpuTime,
            medianCPUTime:      medianCPUTime,
            cpuTimeLimit:       cpuTimeLimit,
            memory:             memory,
            medianMemory:       medianMemory,
            memoryLimit:        memoryLimit
        ))
    }
}
