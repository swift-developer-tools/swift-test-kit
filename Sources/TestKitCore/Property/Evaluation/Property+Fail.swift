//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension PropertyResult
{
    // MARK: - Emit
    
    /// Emits the property check result.
    /// - Parameters:
    ///   - functionName: The property evaluator function name.
    ///   - statistics: The command statistics for stateful tests.
    ///   - context: The assertion failure context.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    internal func emit(
        functionName    : String,
        statistics      : String?           = nil,
        context         : FailureContext ,
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
            case .passed:
                
                return
                
            case let .failed(counterexample, dist, tableDist):
                
                text = formatCounterexample(
                    counterexample,
                    functionName:       functionName,
                    statistics:         statistics,
                    message:            message,
                    distribution:       dist,
                    tableDistribution:  tableDist
                )
                
            case let .exhausted(
                discarded, succeeded, ratio, seed, dist, tableDist
            ):
                
                text = formatExhausted(
                    functionName:       functionName,
                    statistics:         statistics,
                    message:            message,
                    discarded:          discarded,
                    succeeded:          succeeded,
                    ratio:              ratio,
                    seed:               seed,
                    distribution:       dist,
                    tableDistribution:  tableDist
                )
                
            case let .coverageNotMet(unmet, iterations, seed, dist, tableDist):
                
                text = formatCoverageNotMet(
                    functionName:       functionName,
                    statistics:         statistics,
                    message:            message,
                    unmet:              unmet,
                    iterations:         iterations,
                    seed:               seed,
                    distribution:       dist,
                    tableDistribution:  tableDist
                )
        }
        
        context.emit(
            text,
            fileID,
            file,
            line,
            column
        )
    }
    
    
    
    // MARK: - Counterexample
    
    /// Creates a counterexample failure message.
    /// - Parameters:
    ///   - counterexample: The counterexample to format.
    ///   - functionName: The property evaluator function name.
    ///   - statistics: The command statistics for stateful tests.
    ///   - message: The description of a failure.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    /// - Returns: The counterexample failure message.
    private func formatCounterexample(
        _ counterexample    : Counterexample<T>,
        functionName        : String,
        statistics          : String?,
        message             : () -> String,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    ) -> String
    {
        if counterexample.failingStep != nil
        {
            return formatStatefulCounterexample(
                counterexample,
                functionName:       functionName,
                statistics:         statistics,
                message:            message,
                distribution:       distribution,
                tableDistribution:  tableDistribution
            )
        }
        
        
        
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
        
        
        
        return Self.finishCounterexampleMessage(
            counterexample,
            lines:              lines,
            functionName:       functionName,
            statistics:         statistics,
            message:            message,
            distribution:       distribution,
            tableDistribution:  tableDistribution
        )
    }
    
    
    
    /// Creates a stateful counterexample failure message.
    /// - Parameters:
    ///   - counterexample: The counterexample to format.
    ///   - functionName: The property evaluator function name.
    ///   - statistics: The command statistics for stateful tests.
    ///   - message: The description of a failure.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    /// - Returns: The stateful counterexample failure message.
    private func formatStatefulCounterexample(
        _ counterexample    : Counterexample<T>,
        functionName        : String,
        statistics          : String?,
        message             : () -> String,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    ) -> String
    {
        let commandMirror   : Mirror  = .init(reflecting: counterexample.value)
        let commandCount    : Int     = commandMirror.children.count
        
        
        
        var lines: [String] = []
        
        var header: String
            = "\(functionName) failed after \(counterexample.iteration)"
            + " iteration\(counterexample.iteration == 1 ? "" : "s")"
        
        if counterexample.shrinkSteps > 0
        {
            header += " (shrunk to \(commandCount)"
            header += " command\(commandCount == 1 ? "" : "s")"
            header += ")"
        }
        
        lines.append(header)
        
        
        
        let failingStep : Int       = counterexample.failingStep ?? commandCount
        let commands    : [Any]     = commandMirror.children.map { $0.value }
        
        lines.append("")
        lines.append("Command sequence:")
        
        let digitWidth: Int = String(commandCount).count
        
        for (index, command) in commands.enumerated()
        {
            let step        : Int       = index + 1
            let stepString  : String    = .init(step)
            
            let padding = String(
                repeating:  " ",
                count:      digitWidth - stepString.count
            )
            
            var line: String 
                = "    \(padding + stepString). \(String(describing: command))"
            
            if step == failingStep
            {
                line += " ←"
            }
            
            lines.append(line)
        }
        
        
        
        return Self.finishCounterexampleMessage(
            counterexample,
            lines:              lines,
            functionName:       functionName,
            statistics:         statistics,
            message:            message,
            distribution:       distribution,
            tableDistribution:  tableDistribution
        )
    }

    
    
    // MARK: - Exhausted
    
    /// Creates an exhaustion failure message.
    /// - Parameters:
    ///   - functionName: The property evaluator function name.
    ///   - statistics: The command statistics for stateful tests.
    ///   - message: The description of a failure.
    ///   - discarded: The number of discarded values.
    ///   - succeeded: The number of successful values.
    ///   - ratio: The maximum ratio of discarded values to successful values.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    /// - Returns: The exhaustion failure message.
    private func formatExhausted(
        functionName        : String,
        statistics          : String?,
        message             : () -> String,
        discarded           : Int,
        succeeded           : Int,
        ratio               : Int,
        seed                : UInt64,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(
            "\(functionName) exhausted after \(succeeded) successful"
            + " iteration\(succeeded == 1 ? "" : "s")"
        )
        
        lines.append("")
        
        lines.append(
            "    \(discarded) value\(discarded == 1 ? "" : "s") discarded"
            + " (max ratio: \(ratio))"
        )
        
        lines.append("")
        lines.append(Self.makeSeedLine(
            seed:           seed,
            functionName:   functionName
        ))
        
        lines = Self.addDistributionLines(
            to:                 lines,
            iterations:         succeeded,
            distribution:       distribution,
            tableDistribution:  tableDistribution
        )
        
        if let statistics
        {
            lines.append("")
            lines.append(statistics)
        }
        
        lines = Self.addMessageLines(
            to:         lines,
            message:    message
        )
        
        return lines.joined(separator: "\n")
    }
    
    
    
    // MARK: - Coverage
    
    /// Creates an unmet coverage failure message.
    /// - Parameters:
    ///   - functionName: The property evaluator function name.
    ///   - statistics: The command statistics for stateful tests.
    ///   - message: The description of a failure.
    ///   - unmet: The unmet coverage requirements.
    ///   - iterations: The number of iterations.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    /// - Returns: The unmet coverage failure message.
    private func formatCoverageNotMet(
        functionName        : String,
        statistics          : String?,
        message             : () -> String,
        unmet               : [UnmetCoverage],
        iterations          : Int,
        seed                : UInt64,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(
            "\(functionName) coverage not met after \(iterations)"
            + " iteration\(iterations == 1 ? "" : "s")"
        )
        
        lines.append("")
        lines.append("Coverage:")
        
        let flatLines: [String] = Self.formatCoverageLines(
            distribution,
            unmet:          unmet.filter { $0.table == nil },
            iterations:     iterations,
            indent:         "    "
        )
        
        lines.append(contentsOf: flatLines)
        
        let tableLines: [String] = Self.formatTableCoverage(
            tableDistribution,
            unmet:          unmet,
            iterations:     iterations
        )
        
        if
            !flatLines.isEmpty,
            !tableLines.isEmpty
        {
            lines.append("")
        }
        
        lines.append(contentsOf: tableLines)
        
        
        
        lines.append("")
        lines.append(Self.makeSeedLine(
            seed:           seed,
            functionName:   functionName
        ))
        
        if let statistics
        {
            lines.append("")
            lines.append(statistics)
        }
        
        lines = Self.addMessageLines(
            to:         lines,
            message:    message
        )
        
        return lines.joined(separator: "\n")
    }
    
    
    
    /// Formats the given table distribution data as coverage lines with
    /// the given unmet requirements marked.
    /// - Parameters:
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    ///   - unmet: The unmet coverage requirements.
    ///   - iterations: The number of iterations.
    /// - Returns: The formatted lines.
    private static func formatTableCoverage(
        _ tableDistribution : [String : [String : Int]],
        unmet               : [UnmetCoverage],
        iterations          : Int
    ) -> [String]
    {
        /// Group the unmet requirements by table name.
        let unmetByTable: [String : [UnmetCoverage]] = Dictionary(
            grouping:   unmet.filter { $0.table != nil },
            by:         { $0.table! }
        )
        
        var allTables: Set<String> = Set(tableDistribution.keys)
        
        allTables.formUnion(unmetByTable.keys)
        
        guard !allTables.isEmpty
        else
        {
            return []
        }
        
        
        
        var lines   : [String]  = []
        var isFirst : Bool      = true
        
        for tableName in allTables.sorted()
        {
            if !isFirst
            {
                lines.append("")
            }
            
            isFirst = false
            
            lines.append("    Table \(quote(tableName)):")
            
            let tableLines: [String] = formatCoverageLines(
                tableDistribution[tableName] ?? [:],
                unmet:          unmetByTable[tableName] ?? [],
                iterations:     iterations,
                indent:         "        "
            )
            
            lines.append(contentsOf: tableLines)
        }
        
        return lines
    }
    
    
    
    /// Formats coverage lines for a single scope (flat labels or one table).
    /// - Parameters:
    ///   - distribution: The label counts for this scope.
    ///   - unmet: The pre-filtered unmet requirements for this scope.
    ///   - iterations: The number of iterations.
    ///   - indent: The indentation prefix for each line.
    /// - Returns: The formatted lines.
    private static func formatCoverageLines(
        _ distribution  : [String : Int],
        unmet           : [UnmetCoverage],
        iterations      : Int,
        indent          : String
    ) -> [String]
    {
        let unmetLabels : Set<String>   = Set(unmet.map { $0.label })
        var allLabels   : Set<String>   = Set(distribution.keys)
        
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
        
        
        
        return percentages.map
        {
            label, percentage in
            
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
            
            var line: String = "\(indent)\(paddedLabel) \(paddedPercentage)%"
            
            if unmetLabels.contains(label)
            {
                let req: UnmetCoverage = unmet.first { $0.label == label }!
                
                line += " (required: \(Self.formatPercentage(req.required))%)"
                line += " ←"
            }
            
            return line
        }
    }
    
    
    
    // MARK: - Support
    
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
    
    
    
    /// Creates a seed re-run line with the given seed and function name.
    /// - Parameters:
    ///   - seed: The seed.
    ///   - counterexample: The function name.
    /// - Returns: The seed re-run line.
    private static func makeSeedLine(
        seed            : UInt64,
        functionName    : String
    ) -> String
    {
        return "Seed: \(seed) (\(functionName))"
    }
    
    
    
    /// Appends formatted lines for counterexample failures or thrown errors
    /// to the given lines.
    /// - Parameters:
    ///   - originalLines: The lines to update.
    ///   - counterexample: The counterexample to use.
    /// - Returns: The updated lines.
    private static func addErrorLines(
        to originalLines    : [String],
        counterexample      : Counterexample<T>
    ) -> [String]
    {
        var lines: [String] = originalLines
        
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
        
        return lines
    }
    
    
    
    /// Appends formatted lines for the given distributions to the given lines.
    /// - Parameters:
    ///   - originalLines: The lines to update.
    ///   - iterations: The number of iterations.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    /// - Returns: The updated lines.
    private static func addDistributionLines(
        to originalLines    : [String],
        iterations          : Int,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    ) -> [String]
    {
        guard
            !distribution.isEmpty
            || !tableDistribution.isEmpty
        else
        {
            return originalLines
        }
        
        var lines: [String] = originalLines
        
        lines.append("")
        
        lines.append(Self.makeDistributionHeader(
            iterations: iterations
        ))
        
        let flatLines: [String] = Self.formatDistribution(
            distribution,
            iterations: iterations
        )
        
        lines.append(contentsOf: flatLines)
        
        let tableLines: [String] = Self.formatTableDistribution(
            tableDistribution,
            iterations: iterations
        )
        
        if
            !flatLines.isEmpty,
            !tableLines.isEmpty
        {
            lines.append("")
        }
        
        lines.append(contentsOf: tableLines)
        
        return lines
    }
    
    
    
    /// Appends a formatted line for the given message to the given lines.
    /// - Parameters:
    ///   - originalLines: The lines to update.
    ///   - message: The description of a failure.
    /// - Returns: The updated lines.
    private static func addMessageLines(
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
    
    
    
    /// Formats the given table distribution data as indented lines.
    /// - Parameters:
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    ///   - iterations: The number of iterations.
    /// - Returns: The formatted lines.
    internal static func formatTableDistribution(
        _ tableDistribution : [String : [String : Int]],
        iterations          : Int
    ) -> [String]
    {
        var lines   : [String]  = []
        var isFirst : Bool      = true
        
        for tableName in tableDistribution.keys.sorted()
        {
            let tableLines: [String] = formatDistribution(
                tableDistribution[tableName]!,
                iterations: iterations
            )
            
            if !isFirst
            {
                lines.append("")
            }
            
            isFirst = false
            
            lines.append("    Table \(quote(tableName)):")
            
            for line in tableLines
            {
                lines.append("    \(line)")
            }
        }
        
        return lines
    }
    
    
    
    /// Finishes formatting the given counterexample failure message.
    ///
    /// This appends lines for the seed, distributions, any failures or errors,
    /// and the message, then joins the lines.
    ///
    /// - Parameters:
    ///   - counterexample: The counterexample to format.
    ///   - originalLines: The lines to update.
    ///   - statistics: The command statistics for stateful tests.
    ///   - message: The description of a failure.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    /// - Returns: The counterexample failure message.
    private static func finishCounterexampleMessage(
        _ counterexample    : Counterexample<T>,
        lines originalLines : [String],
        functionName        : String,
        statistics          : String?,
        message             : () -> String,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    ) -> String
    {
        var lines: [String] = originalLines
        
        lines = Self.addErrorLines(
            to:                 lines,
            counterexample:     counterexample
        )
        
        lines.append("")
        lines.append(Self.makeSeedLine(
            seed:           counterexample.seed,
            functionName:   functionName
        ))
        
        lines = Self.addDistributionLines(
            to:                 lines,
            iterations:         counterexample.iteration,
            distribution:       distribution,
            tableDistribution:  tableDistribution
        )
        
        if let statistics
        {
            lines.append("")
            lines.append(statistics)
        }
        
        lines = Self.addMessageLines(
            to:         lines,
            message:    message
        )
        
        return lines.joined(separator: "\n")
    }
}
