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
                
            case let .failed(counterexample, distribution):
                
                text = formatCounterexample(
                    counterexample,
                    functionName:   functionName,
                    message:        message,
                    distribution:   distribution
                )
                
            case let .exhausted(
                discarded, succeeded, ratio, seed, distribution
            ):
                
                text = formatExhausted(
                    functionName:   functionName,
                    message:        message,
                    discarded:      discarded,
                    succeeded:      succeeded,
                    ratio:          ratio,
                    seed:           seed,
                    distribution:   distribution
                )
                
            case let .coverageNotMet(unmet, iterations, seed, distribution):
                
                text = formatCoverageNotMet(
                    functionName:   functionName,
                    message:        message,
                    unmet:          unmet,
                    iterations:     iterations,
                    seed:           seed,
                    distribution:   distribution
                )
        }
        
        context.emit(
            text,
            file,
            line
        )
    }
    
    
    
    /// Creates a counterexample failure message.
    /// - Parameters:
    ///   - counterexample: The counterexample to format.
    ///   - functionName: The name of the property-based function.
    ///   - message: The description of a failure.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    /// - Returns: The counterexample failure message.
    private func formatCounterexample(
        _ counterexample    : Counterexample<T>,
        functionName        : String,
        message             : () -> String,
        distribution        : [String : Int]
    ) -> String
    {
        var lines: [String] = []
        
        var header: String
            = "\(functionName) failed after \(counterexample.iteration)"
            + " iteration\(counterexample.iteration == 1 ? "" : "s")"
        
        if counterexample.shrinkSteps > 0
        {
            header += " (shrunk in \(counterexample.shrinkSteps) step"
            header += "\(counterexample.shrinkSteps == 1 ? "" : "s")"
            header += ")"
        }
        
        lines.append(header)
        
        
        
        let mirror  : Mirror    = .init(reflecting: counterexample.value)
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
            let valueTypeName
                = String(describing: type(of: counterexample.value))
            
            let valueText = String(describing: counterexample.value)
            
            lines.append("    \(valueTypeName) = \(valueText)")
        }
        
        
        
        lines.append("")
        lines.append(Self.makeSeedLine(seed: counterexample.seed))
        
        
        
        if !distribution.isEmpty
        {
            lines.append("")
            
            lines.append(Self.makeDistributionHeader(
                iterations: counterexample.iteration
            ))
            
            let distributionLines: [String] = Self.formatDistribution(
                distribution,
                iterations: counterexample.iteration
            )
            
            lines.append(contentsOf: distributionLines)
        }
        
        
        
        if let failure: InterceptedFailure = counterexample.failures.first
        {
            lines.append("")
            lines.append(failure.message)
        }
        else if let error: Error = counterexample.thrownError
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
    
    
    
    /// Creates an unmet coverage failure message.
    /// - Parameters:
    ///   - functionName: The name of the property-based function.
    ///   - message: The description of a failure.
    ///   - unmet: The unmet coverage requirements.
    ///   - iterations: The number of iterations.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    /// - Returns: The unmet coverage failure message.
    private func formatCoverageNotMet(
        functionName    : String,
        message         : () -> String,
        unmet           : [UnmetCoverage],
        iterations      : Int,
        seed            : UInt64,
        distribution    : [String : Int]
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(
            "\(functionName) coverage not met after \(iterations)"
            + " iteration\(iterations == 1 ? "" : "s")"
        )
        
        
        
        let unmetLabels: Set<String> = Set(unmet.map { $0.label })
        
        /// All labels from `distribution`, plus any unmet labels that had
        /// zero occurences.
        var allLabels: Set<String> = Set(distribution.keys)
        
        allLabels.formUnion(unmetLabels)
        
        
        
        let sorted: [String] = allLabels.sorted()
        
        let percentages: [(String, Int)] = sorted.map
        {
            label in
            
            let count: Int = distribution[label] ?? 0
            
            let percentage: Double = iterations > 0
                ? Double(count) / Double(iterations) * 100.0
                : 0.0
            
            return (label, Int(percentage.rounded()))
        }
        
        let maxPercentageWidth: Int = percentages
            .map { String($0.1).count }
            .max() ?? 1
        
        let maxLabelWidth: Int = sorted
            .map { $0.count }
            .max() ?? 0
        
        
        
        lines.append("")
        lines.append("Coverage:")
        
        for (label, percentage) in percentages
        {
            let percentageString = String(percentage)
            
            let paddedPercentage = String(
                repeating:  " ",
                count:      max(0, maxPercentageWidth - percentageString.count)
            ) + percentageString
            
            let paddedLabel = "\(label):".padding(
                toLength:       maxLabelWidth + 1,
                withPad:        " ",
                startingAt:     0
            )
            
            var line: String = "    \(paddedLabel) \(paddedPercentage)%"
            
            if unmetLabels.contains(label)
            {
                let req: UnmetCoverage = unmet.first { $0.label == label }!
                
                line += " (required: \(Self.formatPercentage(req.required))%)"
                line += " ←"
            }
            
            lines.append(line)
        }
        
        
        
        lines.append("")
        lines.append(Self.makeSeedLine(seed: seed))
        
        
        
        let msg: String = message()
        
        if !msg.isEmpty
        {
            lines.append("")
            lines.append(msg)
        }
        
        return lines.joined(separator: "\n")
    }
    
    
    
    /// Creates an exhaustion failure message.
    /// - Parameters:
    ///   - functionName: The name of the property-based function.
    ///   - message: The description of a failure.
    ///   - discarded: The number of discarded inputs.
    ///   - succeeded: The number of successful inputs.
    ///   - ratio: The maximum ratio of discarded inputs to successful inputs.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    /// - Returns: The exhaustion failure message.
    private func formatExhausted(
        functionName    : String,
        message         : () -> String,
        discarded       : Int,
        succeeded       : Int,
        ratio           : Int,
        seed            : UInt64,
        distribution    : [String : Int]
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
        lines.append(Self.makeSeedLine(seed: seed))
        
        
        
        if !distribution.isEmpty
        {
            lines.append("")
            lines.append(Self.makeDistributionHeader(iterations: succeeded))
            
            let distributionLines: [String] = Self.formatDistribution(
                distribution,
                iterations: succeeded
            )
            
            lines.append(contentsOf: distributionLines)
        }
        
        
        
        let msg: String = message()
        
        if !msg.isEmpty
        {
            lines.append("")
            lines.append(msg)
        }
        
        return lines.joined(separator: "\n")
    }
    
    
    
    
    /// Creates a distribution header with the given number of iterations.
    /// - Parameter iterations: The number of iterations.
    /// - Returns: The distribution header.
    private static func makeDistributionHeader(
        iterations: Int
    ) -> String
    {
        return "Distribution (\(iterations)"
        + " iteration\(iterations == 1 ? "" : "s")):"
    }
    
    
    
    /// Creates a seed re-run line with the given seed.
    /// - Parameter seed: The seed to use.
    /// - Returns: The seed re-run line.
    private static func makeSeedLine(
        seed: UInt64
    ) -> String
    {
        return "Seed: \(seed) (re-run with PropertyOptions.seed)"
    }
    
    
    
    /// Formats the given value as a percentage.
    ///
    /// Integer values are displayed without a decimal point. Non-integer
    /// values are displayed with one decimal place.
    ///
    /// - Parameter value: The value to format.
    /// - Returns: The formatted percentage.
    private static func formatPercentage(
        _ value: Double
    ) -> String
    {
        if value == value.rounded()
        {
            return String(Int(value))
        }
        
        return String(format: "%.1f", value)
    }
    
    
    
    /// Formats the given distribution data as indented lines.
    /// - Parameters:
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - iterations: The number of iterations.
    /// - Returns: The formatted lines.
    internal static func formatDistribution(
        _ distribution  : [String : Int],
        iterations      : Int
    ) -> [String]
    {
        let sorted: [(String, Int)] = distribution.sorted { $0.key < $1.key }
        
        let maxLabelWidth: Int = sorted
            .map { $0.0.count }
            .max() ?? 0
        
        return sorted.map
        {
            label, count in
            
            let percentage: Double = iterations > 0
                ? (Double(count) / Double(iterations) * 100.0)
                : 0.0
            
            let formatted: String = formatPercentage(percentage)
            
            let paddedLabel = "\(label):".padding(
                toLength:       maxLabelWidth + 1,
                withPad:        " ",
                startingAt:     0
            )
            
            return "    \(paddedLabel) \(count) (\(formatted)%)"
        }
    }
}
