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
        let result: PerformanceResult = .completed(measurements: .init(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(50), count: 5),
            medianWallTime:     .milliseconds(50),
            wallTimeLimit:      .milliseconds(10),
            memory:             nil,
            medianMemory:       nil,
            memoryLimit:        nil
        ))
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold: 10 ms
            Median:    50 ms (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testWallTimeDifferentWidth()
    {
        let result: PerformanceResult = .completed(measurements: .init(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(123), count: 5),
            medianWallTime:     .milliseconds(123),
            wallTimeLimit:      .milliseconds(50),
            memory:             nil,
            medianMemory:       nil,
            memoryLimit:        nil
        ))
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold:  50 ms
            Median:    123 ms (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMemoryDifferentWidth()
    {
        let result: PerformanceResult = .completed(measurements: .init(
            runs:               3,
            wallTime:           nil,
            medianWallTime:     nil,
            wallTimeLimit:      nil,
            memory:             Array(repeating: .kilobytes(512), count: 3),
            medianMemory:       .kilobytes(512),
            memoryLimit:        .kilobytes(1)
        ))
        
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
        let result: PerformanceResult = .completed(measurements: .init(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(5), count: 5),
            medianWallTime:     .milliseconds(5),
            wallTimeLimit:      .milliseconds(500),
            memory:             Array(repeating: .megabytes(2.5), count: 5),
            medianMemory:       .megabytes(2.5),
            memoryLimit:        .megabytes(1)
        ))
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
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
        let result: PerformanceResult = .completed(measurements: .init(
            runs:               5,
            wallTime:           Array(repeating: .milliseconds(123), count: 5),
            medianWallTime:     .milliseconds(123),
            wallTimeLimit:      .milliseconds(50),
            memory:             Array(repeating: .megabytes(2.5), count: 5),
            medianMemory:       .megabytes(2.5),
            memoryLimit:        .megabytes(1)
        ))
        
        let actual: String? = emit(result)
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
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
