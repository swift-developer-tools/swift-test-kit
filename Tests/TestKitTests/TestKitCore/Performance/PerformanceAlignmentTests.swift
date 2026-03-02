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
    func testTimeEqualWidth()
    {
        let result: PerformanceResult = .completed(measurements: .init(
            runs:           5,
            time:           Array(repeating: .milliseconds(50), count: 5),
            medianTime:     .milliseconds(50),
            timeLimit:      .milliseconds(10),
            memory:         nil,
            medianMemory:   nil,
            memoryLimit:    nil
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
    
    
    
    func testTimeDifferentWidth()
    {
        let result: PerformanceResult = .completed(measurements: .init(
            runs:           5,
            time:           Array(repeating: .milliseconds(123), count: 5),
            medianTime:     .milliseconds(123),
            timeLimit:      .milliseconds(50),
            memory:         nil,
            medianMemory:   nil,
            memoryLimit:    nil
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
            runs:           3,
            time:           nil,
            medianTime:     nil,
            timeLimit:      nil,
            memory:         Array(repeating: UInt64(524_288), count: 3),
            medianMemory:   524_288,
            memoryLimit:    1024
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
    
    
    
    func testBothOneExceeded()
    {
        let result: PerformanceResult = .completed(measurements: .init(
            runs:           5,
            time:           Array(repeating: .milliseconds(5), count: 5),
            medianTime:     .milliseconds(5),
            timeLimit:      .milliseconds(500),
            memory:         Array(repeating: UInt64(2_500_000), count: 5),
            medianMemory:   2_500_000,
            memoryLimit:    1_048_576
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
            Median:    2.4 MB (5 runs) ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testBothExceeded()
    {
        let result: PerformanceResult = .completed(measurements: .init(
            runs:           5,
            time:           Array(repeating: .milliseconds(123), count: 5),
            medianTime:     .milliseconds(123),
            timeLimit:      .milliseconds(50),
            memory:         Array(repeating: UInt64(2_500_000), count: 5),
            medianMemory:   2_500_000,
            memoryLimit:    1_048_576
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
            Median:    2.4 MB (5 runs) ←
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
