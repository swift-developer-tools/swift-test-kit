//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Formatter
{
    /// Appends formatted lines for the given error to the given lines.
    /// - Parameters:
    ///   - originalLines: The lines to update.
    ///   - error: The thrown error.
    /// - Returns: The updated lines.
    internal static func addErrorLines(
        to originalLines    : [String],
        error               : Error?
    ) -> [String]
    {
        guard let error
        else
        {
            return originalLines
        }
        
        var lines: [String] = originalLines
        
        lines.append("")
        lines.append("Threw error: \(error)")
        
        return lines
    }
    
    
    
    /// Appends formatted lines for the given message to the given lines.
    /// - Parameters:
    ///   - originalLines: The lines to update.
    ///   - message: The description of a failure.
    /// - Returns: The updated lines.
    internal static func addMessageLines(
        to originalLines    : [String],
        message             : () -> String,
    ) -> [String]
    {
        let msg: String = message()
        
        if msg.isEmpty
        {
            return originalLines
        }
        
        var lines: [String] = originalLines
        
        lines.append("")
        lines.append(msg)
        
        return lines
    }
    
    
    
    /// Appends formatted lines for the given intercepted failures to the
    /// given lines.
    /// - Parameters:
    ///   - originalLines: The lines to update.
    ///   - failures: The intercepted failures.
    ///   - showAll: Whether to show all the intercepted failures.
    /// - Returns: The updated lines.
    internal static func addInterceptedFailures(
        to originalLines    : [String],
        failures            : [InterceptedFailure],
        showAll             : Bool
    ) -> [String]
    {
        guard !failures.isEmpty
        else
        {
            return originalLines
        }
        
        var lines: [String] = originalLines
        
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
                    .split(
                        separator:                  "\n",
                        omittingEmptySubsequences:  false
                    )
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
        
        return lines
    }
}
