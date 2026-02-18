//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

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
    
    
    
    /// Initializes a ``PropertyInterceptor`` instance.
    package init()
    {
        self.state = Mutex(InterceptorState())
    }
    
    
    
    /// Whether a failure has been recorded.
    package var didFail: Bool
    {
        return !failures.isEmpty
    }
    
    
    
    /// The recorded failures.
    package var failures: [InterceptedFailure]
    {
        return state.withLock { $0.failures }
    }
    
    
    
    /// Labels applied to the current iteration.
    package var labels: Set<String>
    {
        return state.withLock { $0.labels }
    }
    
    
    
    /// The accumulated count of iterations that matched each label.
    package var distribution: [String : Int]
    {
        return state.withLock { $0.distribution }
    }
    
    
    
    /// The minimum percentage required for each label.
    package var coverageRequirements: [String : Double]
    {
        return state.withLock { $0.coverageRequirements }
    }
    
    
    
    /// Records an assertion failure.
    /// - Parameters:
    ///   - message: The failure message.
    ///   - file: The file where the failure occurred.
    ///   - line: The line where the failure occurred.
    package func record(
        message : String,
        file    : StaticString,
        line    : UInt
    )
    {
        let failure = InterceptedFailure(
            message:    message,
            file:       file,
            line:       line
        )
        
        state.withLock { $0.failures.append(failure) }
    }
    
    
    
    /// Records a label for the current iteration.
    ///
    /// Multiple calls with the same label within a single iteration are
    /// idempotent.
    ///
    /// - Parameter label: The label to record.
    package func recordLabel(
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
    package func recordCoverageRequirement(
        _       percentage  : Double,
        for     label       : String
    )
    {
        let clamped: Double = percentage.clamped(to: 0.0...100.0)
        
        state.withLock
        {
            let existing: Double = $0.coverageRequirements[label] ?? 0.0
            
            $0.coverageRequirements[label] = max(existing, clamped)
        }
    }
    
    
    
    /// Gets the unmet coverage requirements.
    /// - Parameter iterations: The total number of successful iterations.
    /// - Returns: The unmet coverage requirements, or an empty array if
    /// all requirments are met.
    package func checkCoverage(
        iterations: Int
    ) -> [UnmetCoverage]
    {
        return state.withLock
        {
            state in
            
            return state.coverageRequirements.compactMap
            {
                label, required in
                
                let count: Int = state.distribution[label] ?? 0
                
                let actual: Double = iterations > 0
                    ? Double(count) / Double(iterations) * 100.0
                    : 0.0
                
                guard actual < required
                else
                {
                    return nil
                }
                
                return UnmetCoverage(
                    label:      label,
                    required:   required,
                    actual:     actual,
                    table:      nil
                )
            }
        }
    }
    
    
    
    /// Flushes the current iteration's labels into the accumulated label
    /// counts, then clears the per-iteraton label set.
    ///
    /// This is called by ``PropertyRunner`` at the end of each successful
    /// iteration.
    package func finalizeIteration()
    {
        state.withLock
        {
            for label in $0.labels
            {
                $0.distribution[label, default: 0] += 1
            }
            
            $0.labels = []
        }
    }
    
    
    
    /// Resets the interceptor for reuse.
    ///
    /// This is used to reset the interceptor between shrink attempts.
    ///
    /// - Note: The distribution and coverage requirements are not cleared,
    /// since they accumulate across iterations.
    package func reset()
    {
        state.withLock
        {
            $0.failures     = []
            $0.labels       = []
        }
    }
}



// MARK: - InterceptorState

/// The state of ``PropertyInterceptor``.
private struct InterceptorState: Equatable, Sendable
{
    /// Assertion failures for the current iteration.
    var failures                : [InterceptedFailure]  = []
    
    /// Labels applied to the current iteration.
    var labels                  : Set<String>           = []
    
    /// The accumulated count of iterations that matched each label.
    var distribution            : [String : Int]        = [:]
    
    /// The minimum percentage required for each label.
    var coverageRequirements    : [String : Double]     = [:]
}



// MARK: - InterceptedFailure

/// A failure intercepted during property evaluation.
package struct InterceptedFailure: Equatable, Sendable
{
    /// The failure message.
    package let message : String
    
    /// The file where the failure occurred.
    package let file    : StaticString
    
    /// The line where the failure occurred.
    package let line    : UInt
    
    
    
    package static func == (
        lhs: InterceptedFailure,
        rhs: InterceptedFailure
    ) -> Bool
    {
        return lhs.message == rhs.message
            && lhs.file.description == rhs.file.description
            && lhs.line == rhs.line
    }
}
