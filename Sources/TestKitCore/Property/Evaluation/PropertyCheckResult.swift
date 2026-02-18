//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The result of a property check.
package enum PropertyCheckResult<T>
{
    /// All iterations passed.
    /// - Parameters:
    ///   - iterations: The number of iterations.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    case passed(
        iterations          : Int,
        seed                : UInt64,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    )
    
    /// A counterexample was found.
    /// - Parameters:
    ///   - counterexample: The found counterexample.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    case failed(
        counterexample      : Counterexample<T>,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    )
    
    /// Too many inputs did not meet the preconditions of conditional
    /// properties.
    /// - Parameters:
    ///   - discarded: The number of discarded inputs.
    ///   - succeeded: The number of successful inputs.
    ///   - ratio: The maximum ratio of discarded inputs to successful inputs.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    case exhausted(
        discarded           : Int,
        succeeded           : Int,
        ratio               : Int,
        seed                : UInt64,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    )
    
    /// All iterations passed, but one or more coverage requirements were
    /// not met.
    /// - Parameters:
    ///   - unmet: The unmet coverage requirements.
    ///   - iterations: The number of iterations.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - distribution: The accumulated count of iterations that matched
    ///   each label.
    ///   - tableDistribution: The accumulated count of iterations that
    ///   matched each table value, mapping the table name to a map of values
    ///   and their counts.
    case coverageNotMet(
        unmet               : [UnmetCoverage],
        iterations          : Int,
        seed                : UInt64,
        distribution        : [String : Int],
        tableDistribution   : [String : [String : Int]]
    )
}
