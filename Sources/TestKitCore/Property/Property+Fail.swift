//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension PropertyCheckResult
{
    /// Emits the property check result.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    package func emit(
        context : FailureContext,
        message : () -> String,
        file    : StaticString,
        line    : UInt
    )
    {
        /// If there are more property-based assertions, this should change.
        let functionName: String = "\(context.framework.rawValue)ForAll"

        let text: String
        
        switch self
        {
            case .passed:
                
                return
                
            case let .failed(counterexample):
                
                text = counterexample.format(
                    functionName:   functionName,
                    message:        message
                )
                
            case let .exhausted(discarded, succeeded, ratio, seed):
                
                text = formatExhausted(
                    functionName:   functionName,
                    message:        message,
                    discarded:      discarded,
                    succeeded:      succeeded,
                    ratio:          ratio,
                    seed:           seed
                )
        }
        
        context.emit(
            text,
            file,
            line
        )
    }
    
    
    
    /// Creates an exhaustion failure message.
    /// - Parameters:
    ///   - functionName: The name of the property-based function.
    ///   - message: The description of a failure.
    ///   - discarded: The number of discarded inputs.
    ///   - succeeded: The number of successful inputs.
    ///   - ratio: The maximum ratio of discarded inputs to successful inputs.
    ///   - seed: The seed used to initialize the random number generator.
    /// - Returns: The exhaustion failure message.
    private func formatExhausted(
        functionName    : String,
        message         : () -> String,
        discarded       : Int,
        succeeded       : Int,
        ratio           : Int,
        seed            : UInt64
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(
            "\(functionName) exhausted after \(succeeded) successful"
            + " iteration\(succeeded == 1 ? "" : "s")"
        )
        
        lines.append("")
        
        lines.append(
            "    \(discarded) input\(discarded == 1 ? "" : "s") discarded"
            + " (max ratio: \(ratio))"
        )
        
        lines.append("")
        lines.append("Seed: \(seed) (re-run with PropertyOptions.seed)")
        
        
        
        let msg: String = message()
        
        if !msg.isEmpty
        {
            lines.append("")
            lines.append(msg)
        }
        
        return lines.joined(separator: "\n")
    }
}



extension Counterexample
{
    /// Creates the counterexample failure message.
    /// - Parameters:
    ///   - functionName: The name of the property-based function.
    ///   - message: The description of a failure.
    /// - Returns: The counterexample failure message.
    package func format(
        functionName    : String,
        message         : () -> String
    ) -> String
    {
        var lines: [String] = []
        
        var header: String 
            = "\(functionName) failed after \(self.iteration)"
            + " iteration\(self.iteration == 1 ? "" : "s")"
        
        if self.shrinkSteps > 0
        {
            header += " (shrunk in \(self.shrinkSteps) step"
            header += "\(self.shrinkSteps == 1 ? "" : "s")"
            header += ")"
        }
        
        lines.append(header)
        
        
        
        let mirror  : Mirror    = .init(reflecting: self.value)
        let values  : [Any]     = mirror.children.map { $0.value }
        
        lines.append("")
        lines.append("Counterexample:")
        
        if
            mirror.displayStyle == .tuple,
            values.count > 1
        {
            for value in values
            {
                let valueTypeName   = String(describing: type(of: value))
                let valueText       = String(describing: value)
                
                lines.append("    \(valueTypeName) = \(valueText)")
            }
        }
        else
        {
            let valueTypeName   = String(describing: type(of: self.value))
            let valueText       = String(describing: self.value)
            
            lines.append("    \(valueTypeName) = \(valueText)")
        }
        
        
        
        lines.append("")
        lines.append("Seed: \(self.seed) (re-run with PropertyOptions.seed)")
        
        
        
        if let failure: InterceptedFailure = self.failures.first
        {
            lines.append("")
            lines.append(failure.message)
        }
        else if let error: Error = self.thrownError
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
