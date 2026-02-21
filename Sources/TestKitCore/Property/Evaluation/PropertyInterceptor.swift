//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import OSLog
import Synchronization



// MARK: - PropertyInterceptor

/// Intercepts assertion failures during property evaluation.
///
/// When an assertion fails inside a property evaluator, the failure message
/// is recorded here instead of being reported to the associated framework.
/// This allows the property body to be re-run for shrinking purposes.
package final class PropertyInterceptor: Sendable
{
    /// The current interceptor, if running inside a property evaluator.
    @TaskLocal
    package static var current  : PropertyInterceptor?
    
    /// The current interceptor state.
    private let state           : Mutex<InterceptorState>
    
    private static let logger = Logger(
        subsystem:  "swift-test-kit",
        category:   "PropertyInterceptor"
    )
    
    
    
    /// Initializes a ``PropertyInterceptor`` instance.
    internal init()
    {
        self.state = Mutex(InterceptorState())
    }
    
    
    
    /// Whether a failure has been recorded.
    internal var didFail: Bool
    {
        return !failures.isEmpty
    }
    
    
    
    /// The recorded failures.
    internal var failures: [InterceptedFailure]
    {
        return state.withLock { $0.failures }
    }
    
    
    
    /// Labels applied to the current iteration.
    internal var labels: Set<String>
    {
        return state.withLock { $0.labels }
    }
    
    
    
    /// The accumulated count of iterations that matched each label.
    internal var distribution: [String : Int]
    {
        return state.withLock { $0.distribution }
    }
    
    
    
    /// The minimum percentage required for each label.
    internal var coverageRequirements: [String : Double]
    {
        return state.withLock { $0.coverageRequirements }
    }
    
    
    
    /// Table labels applied to the current iteration, mapping the table
    /// name to values.
    internal var tableLabels: [String : Set<String>]
    {
        return state.withLock { $0.tableLabels }
    }
    
    
    
    /// The accumulated count of iterations that matched each table value,
    /// mapping the table name to a map of values and their counts.
    internal var tableDistribution: [String : [String : Int]]
    {
        return state.withLock { $0.tableDistribution }
    }
    
    
    
    /// The minimum percentage required for each table value, mapping the
    /// table name to a map of values and their minimum percentages.
    internal var tableCoverageRequirements: [String : [String : Double]]
    {
        return state.withLock { $0.tableCoverageRequirements }
    }
    
    
    
    /// Records the specified assertion failure.
    /// - Parameters:
    ///   - message: An optional description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    package func recordFailure(
        message : String,
        fileID  : StaticString,
        file    : StaticString,
        line    : UInt,
        column  : UInt
    )
    {
        let failure = InterceptedFailure(
            message:    message,
            fileID:     fileID,
            file:       file,
            line:       line,
            column:     column
        )
        
        state.withLock { $0.failures.append(failure) }
    }
    
    
    
    /// Records the given label for the current iteration.
    ///
    /// Multiple calls with the same label within a single iteration are
    /// idempotent.
    ///
    /// - Parameter label: The label to record.
    internal func recordLabel(
        _ label: String
    )
    {
        _ = state.withLock { $0.labels.insert(label) }
    }
    
    
    
    /// Records the given minimum coverage percentage for the given label.
    ///
    /// If the label already has a requirement, the maximum of the existing
    /// and new thresholds is kept.
    ///
    /// - Parameters:
    ///   - percentage: The minimum percentage required. This is clamped to
    ///   the range `0.0...100.0`.
    ///   - label: The label to which the requirement applies.
    internal func recordCoverageRequirement(
        _       percentage  : Double,
        for     label       : String
    )
    {
        let clamped: Double = percentage.clamped(to: 0.0...100.0)
        
        if clamped == 0.0
        {
            Self.logger.warning(
                "Cover passed vacuously - percentage is 0% for \(quote(label))"
            )
        }
        
        state.withLock
        {
            let existing: Double = $0.coverageRequirements[label] ?? 0.0
            
            $0.coverageRequirements[label] = max(existing, clamped)
        }
    }
    
    
    
    /// Records the given label in the specified table for the current
    /// iteration.
    ///
    /// Multiple calls with the same label within a single iteration are
    /// idempotent.
    ///
    /// - Parameters:
    ///   - label: The label to record.
    ///   - table: The table to update.
    internal func recordTableLabel(
        _ label : String,
        table   : String
    )
    {
        _ = state.withLock { $0.tableLabels[table, default: []].insert(label) }
    }
    
    
    
    /// Records the given minimum coverage percentage for the given label
    /// in the specified table.
    ///
    /// If the label already has a requirement, the maximum of the existing
    /// and new thresholds is kept.
    ///
    /// - Parameters:
    ///   - percentage: The minimum percentage required. This is clamped to
    ///   the range `0.0...100.0`.
    ///   - label: The label to which the requirement applies.
    ///   - table: The table to update.
    internal func recordTableCoverageRequirement(
        _       percentage  : Double,
        for     label       : String,
        in      table       : String
    )
    {
        let clamped: Double = percentage.clamped(to: 0.0...100.0)
        
        if clamped == 0.0
        {
            Self.logger.warning(
                "Cover passed vacuously - percentage is 0% for \(quote(label))"
            )
        }
        
        state.withLock
        {
            let existing: Double = $0.tableCoverageRequirements[table]?[label]
                ?? 0.0
            
            $0.tableCoverageRequirements[table, default: [:]][label]
                = max(existing, clamped)
        }
    }
    
    
    
    /// Gets the unmet coverage requirements.
    /// - Parameter iterations: The total number of successful iterations.
    /// - Returns: The unmet coverage requirements, or an empty array if
    /// all requirments are met.
    internal func checkCoverage(
        iterations: Int
    ) -> [UnmetCoverage]
    {
        return state.withLock
        {
            state in
            
            var unmet: [UnmetCoverage] = []
            
            for (label, required) in state.coverageRequirements
            {
                let count: Int = state.distribution[label] ?? 0
                
                let actual: Double = iterations > 0
                    ? Double(count) / Double(iterations) * 100.0
                    : 0.0
                
                if actual < required
                {
                    unmet.append(UnmetCoverage(
                        label:      label,
                        required:   required,
                        actual:     actual,
                        table:      nil
                    ))
                }
            }
            
            for (table, requirements) in state.tableCoverageRequirements
            {
                let tableCounts: [String : Int]
                    = state.tableDistribution[table] ?? [:]
                
                for (label, required) in requirements
                {
                    let count: Int = tableCounts[label] ?? 0
                    
                    let actual: Double = iterations > 0
                        ? Double(count) / Double(iterations) * 100.0
                        : 0.0
                    
                    if actual < required
                    {
                        unmet.append(UnmetCoverage(
                            label:      label,
                            required:   required,
                            actual:     actual,
                            table:      table
                        ))
                    }
                }
            }
            
            return unmet
        }
    }
    
    
    
    /// Flushes the current iteration's labels into the accumulated label
    /// counts, then clears the per-iteraton label set.
    ///
    /// This is called by ``PropertyRunner`` at the end of each successful
    /// iteration.
    internal func finalizeIteration()
    {
        state.withLock
        {
            state in
            
            for label in state.labels
            {
                state.distribution[label, default: 0] += 1
            }
            
            for (tableName, labels) in state.tableLabels
            {
                for label in labels
                {
                    state.tableDistribution[
                        tableName, default: [:]
                    ][label, default: 0] += 1
                }
            }
            
            state.labels       = []
            state.tableLabels  = [:]
        }
    }
    
    
    
    /// Resets the interceptor for reuse.
    ///
    /// This is used to reset the interceptor between shrink attempts.
    ///
    /// - Note: The distribution and coverage requirements are not cleared,
    /// since they accumulate across iterations.
    internal func reset()
    {
        state.withLock
        {
            $0.failures     = []
            $0.labels       = []
            $0.tableLabels  = [:]
        }
    }
}



// MARK: - InterceptorState

/// The state of ``PropertyInterceptor``.
private struct InterceptorState: Equatable, Sendable
{
    /// Assertion failures for the current iteration.
    var failures                    : [InterceptedFailure]          = []
    
    /// Labels applied to the current iteration.
    var labels                      : Set<String>                   = []
    
    /// The accumulated count of iterations that matched each label.
    var distribution                : [String : Int]                = [:]
    
    /// The minimum percentage required for each label.
    var coverageRequirements        : [String : Double]             = [:]
    
    /// Table labels applied to the current iteration, mapping the table
    /// name to labels.
    var tableLabels                 : [String : Set<String>]        = [:]
    
    /// The accumulated count of iterations that matched each table, mapping
    /// the table name to a map of labels and their counts.
    var tableDistribution           : [String : [String : Int]]     = [:]
    
    /// The minimum percentage required for each table value, mapping the
    /// table name to a map of labels and their minimum percentages.
    var tableCoverageRequirements   : [String : [String : Double]]  = [:]
}



// MARK: - InterceptedFailure

/// A failure intercepted during property evaluation.
internal struct InterceptedFailure: Equatable, Sendable
{
    /// The failure message.
    internal let message    : String
    
    /// The ID of the file where the failure occured.
    internal let fileID     : StaticString
    
    /// The file where the failure occurred.
    internal let file       : StaticString
    
    /// The line where the failure occurred.
    internal let line       : UInt
    
    /// The column where the failure occured.
    internal let column     : UInt
    
    
    
    internal static func == (
        lhs: InterceptedFailure,
        rhs: InterceptedFailure
    ) -> Bool
    {
        return lhs.message == rhs.message
            && lhs.fileID.description == rhs.fileID.description
            && lhs.file.description == rhs.file.description
            && lhs.line == rhs.line
            && lhs.column == rhs.column
    }
}
