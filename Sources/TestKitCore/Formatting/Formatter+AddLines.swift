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
}
