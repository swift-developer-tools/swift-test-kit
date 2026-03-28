//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension AtomicResult
{
    // MARK: - Emit
    
    /// Emits the atomic test result.
    /// - Parameters:
    ///   - functionName: The atomic evaluator function name.
    ///   - context: The assertion failure context.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    internal func emit(
        functionName    : String,
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
            case .passed:
                
                return
                
            case let .failed(failures, error):
                
                let text: String = Self.formatFailure(
                    failures:       failures,
                    error:          error,
                    functionName:   functionName,
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
    
    /// Creates an atomic test failure message.
    /// - Parameters:
    ///   - failures: The intercepted failures.
    ///   - error: The thrown error.
    ///   - functionName: The atomic evaluator function name.
    ///   - message: The description of a failure.
    /// - Returns: The atomic test failure message.
    private static func formatFailure(
        failures        : [InterceptedFailure],
        error           : Error?,
        functionName    : String,
        message         : () -> String
    ) -> String
    {
        var lines   : [String]  = []
        var header  : String    = "\(functionName) failed"
        
        if !failures.isEmpty
        {
            header += " ("
            header += "\(failures.count) failed"
            header += " assertion\(failures.count == 1 ? "" : "s")"
            header += ")"
        }
        
        lines.append(header)
        
        lines = Formatter.addInterceptedFailures(
            to:         lines,
            failures:   failures
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
}
