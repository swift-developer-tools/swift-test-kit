//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension PerformanceResult
{
    // MARK: - Emit
    
    /// Emits the performance test result.
    /// - Parameters:
    ///   - runs: The resolved number of measurement runs.
    ///   - warmupRuns: The resolved number of warmup runs.
    ///   - functionName: The performance evaluator function name.
    ///   - options: The options for testing.
    ///   - context: The assertion failure context.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    internal func emit(
        runs            : Int,
        warmupRuns      : Int,
        functionName    : String,
        options         : TestOptions,
        context         : FailureContext,
        message         : () -> String,
        fileID          : StaticString,
        file            : StaticString,
        line            : UInt,
        column          : UInt
    )
    {
        let text: String
        
        switch self
        {
            case
                .noMetrics,
                .canceled:
                
                return
                
            case let .failed(failures, run, warmup, error):
                
                text = Self.formatAssertionFailure(
                    failures:       failures,
                    error:          error,
                    run:            run,
                    totalRuns:      warmup ? warmupRuns : runs,
                    warmup:         warmup,
                    functionName:   functionName,
                    options:        options,
                    message:        message
                )
                
            case let .completed(measurements):
                
                guard !measurements.success
                else
                {
                    return
                }
                
                text = Self.formatMetricViolation(
                    measurements:   measurements,
                    functionName:   functionName,
                    message:        message
                )
        }
        
        if let interceptor = FailureInterceptor.current
        {
            interceptor.recordFailure(
                message:    text,
                fileID:     fileID,
                file:       file,
                line:       line,
                column:     column
            )
        }
        else
        {
            context.emit(
                text,
                fileID,
                file,
                line,
                column
            )
        }
    }
    
    
    
    // MARK: - Assertion failure
    
    /// Creates an assertion failure message.
    /// - Parameters:
    ///   - failures: The intercepted failures.
    ///   - error: The thrown error.
    ///   - run: The 1-indexed run during which the failure occurred.
    ///   - totalRuns: The total number of runs in the phase.
    ///   - warmup: Whether the failure occurred during a warmup run.
    ///   - functionName: The performance evaluator function name.
    ///   - options: The options for testing.
    ///   - message: The description of a failure.
    /// - Returns: The assertion failure message.
    private static func formatAssertionFailure(
        failures        : [InterceptedFailure],
        error           : Error?,
        run             : Int,
        totalRuns       : Int,
        warmup          : Bool,
        functionName    : String,
        options         : TestOptions,
        message         : () -> String
    ) -> String
    {
        var lines: [String] = []
        
        let runLabel: String
            = "\(warmup ? "warmup " : "")run \(run) of \(totalRuns)"
        
        lines.append("\(functionName) failed (\(runLabel))")
        
        lines = Formatter.addInterceptedFailures(
            to:         lines,
            failures:   failures,
            showAll:    options.performanceOptions.showAllFailures
        )
        
        lines = Formatter.addErrorLines(
            to:     lines,
            error:  error
        )
        
        lines = Formatter.addMessageLines(
            to:         lines,
            message:    message
        )
        
        return lines.joined(separator: "\n")
    }
    
    
    
    // MARK: - Metric violation
    
    /// Creates a metric violation failure message.
    /// - Parameters:
    ///   - measurements: The performance measurements.
    ///   - functionName: The performance evaluator function name.
    ///   - message: The description of a failure.
    /// - Returns: The metric violation failure message.
    private static func formatMetricViolation(
        measurements    : PerformanceMeasurements,
        functionName    : String,
        message         : () -> String
    ) -> String
    {
        var lines: [String] = []
        
        lines.append("\(functionName) failed")
        
        if
            let timeLimit   : Duration  = measurements.timeLimit,
            let medianTime  : Duration  = measurements.medianTime
        {
            lines.append("")
            lines.append("Time:")
            
            lines.append(contentsOf: formatMetricLines(
                threshold:  timeLimit.readable,
                median:     medianTime.readable,
                runs:       measurements.runs,
                exceeded:   measurements.timeLimitExceeded
            ))
        }
        
        if
            let memoryLimit     : ByteCount     = measurements.memoryLimit,
            let medianMemory    : ByteCount     = measurements.medianMemory
        {
            lines.append("")
            lines.append("Memory:")
            
            lines.append(contentsOf: formatMetricLines(
                threshold:  memoryLimit.description,
                median:     medianMemory.description,
                runs:       measurements.runs,
                exceeded:   measurements.memoryLimitExceeded
            ))
        }
        
        lines = Formatter.addMessageLines(
            to:         lines,
            message:    message
        )
        
        return lines.joined(separator: "\n")
    }
    
    
    
    /// Formats the given threshold and median values for a single metric.
    /// - Parameters:
    ///   - threshold: The formatted threshold value.
    ///   - median: The formatted median value.
    ///   - runs: The number of measurement runs.
    ///   - exceeded: Whether the median exceeded the threshold.
    /// - Returns: The formatted lines.
    private static func formatMetricLines(
        threshold   : String,
        median      : String,
        runs        : Int,
        exceeded    : Bool
    ) -> [String]
    {
        let thresholdLabel  : String    = "Threshold:"
        let medianLabel     : String    = "Median:"
        
        let maxLabelWidth: Int = max(
            thresholdLabel.count,
            medianLabel.count
        )
        
        let maxValueWidth: Int = max(
            threshold.count,
            median.count
        )
        
        let paddedThresholdLabel = thresholdLabel.padding(
            toLength:       maxLabelWidth,
            withPad:        " ",
            startingAt:     0
        )
        
        let paddedMedianLabel = medianLabel.padding(
            toLength:       maxLabelWidth,
            withPad:        " ",
            startingAt:     0
        )
        
        let paddedThreshold = String(
            repeating:  " ",
            count:      maxValueWidth - threshold.count
        ) + threshold
        
        let paddedMedian = String(
            repeating:  " ",
            count:      maxValueWidth - median.count
        ) + median
        
        let thresholdLine: String
            = "    \(paddedThresholdLabel) \(paddedThreshold)"
        
        var medianLine: String
            = "    \(paddedMedianLabel) \(paddedMedian) (\(runs)"
            + " run\(runs == 1 ? "" : "s"))"
        
        if exceeded
        {
            medianLine += " ←"
        }
        
        return [thresholdLine, medianLine]
    }
}
