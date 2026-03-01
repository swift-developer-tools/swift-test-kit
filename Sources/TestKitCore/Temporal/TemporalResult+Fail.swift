//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension TemporalResult
{
    // MARK: - Emit
    
    /// Emits the temporal test result.
    /// - Parameters:
    ///   - kind: The temporal test kind.
    ///   - timeout: The timeout duration.
    ///   - functionName: The temporal evaluator function name.
    ///   - options: The options for testing.
    ///   - context: The assertion failure context.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    internal func emit(
        kind            : TemporalRunner.Kind,
        timeout         : Duration,
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
        switch self
        {
            case
                .passed,
                .canceled:
                
                return
                
            case let .failed(failures, elapsed, error):
                
                let text: String = Self.formatFailure(
                    kind:           kind,
                    timeout:        timeout,
                    elapsed:        elapsed,
                    failures:       failures,
                    error:          error,
                    functionName:   functionName,
                    options:        options,
                    message:        message
                )
                
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
    }
    
    
    
    // MARK: - Format
    
    /// Creates a temporal test failure message.
    /// - Parameters:
    ///   - kind: The temporal test kind.
    ///   - timeout: The timeout duration.
    ///   - elapsed: The elapsed duration at the point of resolution.
    ///   - error: The error thrown by the assertion.
    ///   - functionName: The temporal evaluator function name.
    ///   - options: The options for testing.
    ///   - message: The description of a failure.
    /// - Returns: The temporal test failure message.
    private static func formatFailure(
        kind            : TemporalRunner.Kind,
        timeout         : Duration,
        elapsed         : Duration,
        failures        : [InterceptedFailure],
        error           : Error?,
        functionName    : String,
        options         : TestOptions,
        message         : () -> String
    ) -> String
    {
        var lines: [String] = []
        
        switch kind
        {
            case .eventually:
                
                lines.append(
                    "\(functionName) failed after \(timeout.readable)"
                )
                
            case .always:
                
                lines.append(
                    "\(functionName) failed after \(elapsed.readable)"
                )
        }
        
        
        
        let showAll: Bool = options.temporalOptions.showAllFailures
        
        let visibleFailures: [InterceptedFailure] = showAll
            ? failures
            : Array(failures.prefix(1))
        
        for (index, failure) in visibleFailures.enumerated()
        {
            lines.append("")
            
            if
                showAll,
                visibleFailures.count > 1
            {
                lines.append("Failure \(index + 1):")
                
                let indented: String = failure.message
                    .split(separator: "\n", omittingEmptySubsequences: false)
                    .map { "    \($0)" }
                    .joined(separator: "\n")
                
                lines.append(indented)
            }
            else
            {
                lines.append(failure.message)
            }
        }
        
        if
            showAll,
            failures.count > visibleFailures.count
        {
            let remaining: Int = failures.count - visibleFailures.count
            
            lines.append("")
            
            lines.append(
                "... and \(remaining) more failure\(remaining == 1 ? "" : "s")"
            )
        }
        
        
        
        if let error
        {
            lines.append("")
            lines.append("Threw error: \(error)")
        }
        
        
        
        let msg: String = message()
        
        if !msg.isEmpty
        {
            lines.append("")
            lines.append(msg)
        }
        
        
        
        return lines.joined(separator: "\n")
    }
}
