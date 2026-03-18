//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - PropertyOptions

/// The options for property-based testing.
public struct PropertyOptions: Equatable, Sendable
{
    /// The number of test iterations.
    ///
    /// The default value is `100`.
    public var iterations       : Int
    
    /// The maximum number of shrink steps per failure.
    ///
    /// The default value is `100`.
    public var maxShrinkSteps   : Int
    
    /// The maximum generation size.
    ///
    /// The default value is `100`.
    ///
    /// - Note: See ``GenerationContext/size`` for more information.
    public var maxSize          : Int
    
    /// The maximum ratio of discarded values to successful values.
    ///
    /// The default value is `10`.
    ///
    /// When using conditional properties, values that do not satisfy the
    /// precondition are discarded. If the discard count exceeds
    /// `maxDiscardRatio * iterations`, the test fails with an exhaustion error.
    public var maxDiscardRatio  : Int
    
    /// The maximum number of commands per stateful test sequence.
    ///
    /// The default value is `100`.
    ///
    /// Command sequence length scales linearly with the generation size,
    /// starting with short sequences in early iterations and growing toward
    /// this maximum value in later iterations.
    public var maxCommandCount  : Int
    
    /// The number of high-target-value entries retained for mutation during
    /// targeted property-based testing.
    ///
    /// The default value is `20`.
    ///
    /// Larger pools maintain more diversity at the cost of slower convergence.
    /// Smaller pools converge faster but risk local optima.
    public var poolSize         : Int
    
    /// The balance between exploration and exploitation during targeted
    /// property-based testing.
    ///
    /// The default value is `0.3`, which means that 30% of iterations generate
    /// a new value (exploration), while 70% of iterations mutate existing pool
    /// entries (exploitation).
    public var explorationRatio : Double
    
    /// The maximum duration for the property-based test, including generation,
    /// evaluation, and shrinking.
    ///
    /// The default value is `nil`, which imposes no time limit. When non-`nil`,
    /// the test will stop once the deadline is exceeded, and will return the
    /// best result found so far.
    public var timeout          : Duration?
    
    /// The options for reporting diagnostics in property-based tests.
    ///
    /// The default value is an empty option set.
    public var diagnostics      : PropertyDiagnostics
    
    /// The options for reporting command statistics in stateful
    /// property-based tests.
    ///
    /// The default value is an empty option set.
    public var statistics       : CommandStatistics
    
    /// The seed used to initialize the random number generator.
    ///
    /// The default value is `nil`. When `nil`, a random seed is generated
    /// from the system random number generator. Set this to a specific value
    /// to reproduce a previous failure.
    public var seed             : UInt64?
    
    
    
    /// Initializes a ``PropertyOptions`` instance, optionally specifying
    /// values for its properties.
    ///
    /// - Precondition: `iterations`, `maxShrinkSteps`, `maxSize`,
    /// `maxDiscardRatio`, and `maxCommandCount` must not be negative.
    /// - Precondition: `poolSize` must be positive.
    /// - Precondition: `explorationRatio` must be in the range `0.0...1.0`.
    ///
    /// - Warning: Very large `maxSize` values can cause significant memory
    /// pressure, especially for collection types, which generate up to
    /// `maxSize` elements per iteration.
    public init(
        iterations          : Int                   = 100,
        maxShrinkSteps      : Int                   = 100,
        maxSize             : Int                   = 100,
        maxDiscardRatio     : Int                   = 10,
        maxCommandCount     : Int                   = 100,
        poolSize            : Int                   = 20,
        explorationRatio    : Double                = 0.3,
        timeout             : Duration?             = nil,
        diagnostics         : PropertyDiagnostics   = [],
        statistics          : CommandStatistics     = [],
        seed                : UInt64?               = nil
    )
    {
        precondition(
            iterations >= 0,
            "iterations must not be negative"
        )
        
        precondition(
            maxShrinkSteps >= 0,
            "maxShrinkSteps must not be negative"
        )
        
        precondition(
            maxSize >= 0,
            "maxSize must not be negative"
        )
        
        precondition(
            maxDiscardRatio >= 0,
            "maxDiscardRatio must not be negative"
        )
        
        precondition(
            maxCommandCount >= 0,
            "maxCommandCount must not be negative"
        )
        
        precondition(
            poolSize > 0,
            "poolSize must be positive"
        )
        
        precondition(
            (0.0...1.0).contains(explorationRatio),
            "explorationRatio must be in the range 0.0...1.0"
        )
        
        self.iterations         = iterations
        self.maxShrinkSteps     = maxShrinkSteps
        self.maxSize            = maxSize
        self.maxDiscardRatio    = maxDiscardRatio
        self.maxCommandCount    = maxCommandCount
        self.poolSize           = poolSize
        self.explorationRatio   = explorationRatio
        self.timeout            = timeout
        self.diagnostics        = diagnostics
        self.statistics         = statistics
        self.seed               = seed
    }
}



// MARK: - PropertyDiagnostics

/// The options for reporting diagnostics in property-based tests.
public struct PropertyDiagnostics: OptionSet, Equatable, Sendable
{
    /// The raw value.
    public let rawValue: Int
    
    
    
    /// Report the original counterexample before shrinking.
    public static let original      = PropertyDiagnostics(rawValue: 1 << 0)
    
    /// Report all generated values and shrink candidates.
    ///
    /// - Note: This is reported using `OSLog`.
    public static let verbose       = PropertyDiagnostics(rawValue: 1 << 1)
    
    /// Report individual iterations that are slower than the median iteration
    /// duration.
    ///
    /// An iteration is considered slow if it exceeds 10 times the median
    /// iteration duration. The slowness check is skipped when the total number
    /// of iterations is fewer than 10, or when the median duration is zero.
    ///
    /// This can help identify pathological values, non-deterministic
    /// performance, accidentally-expensive generators, and tests which have
    /// inherent performance issues but do not exceed the overall time limit.
    ///
    /// - Note: This is reported using `OSLog`.
    public static let slowness       = PropertyDiagnostics(rawValue: 1 << 2)
    
    /// Reports ineffective shrinking that produces no improvements.
    ///
    /// This can help identify shrink implementations that shrink on the
    /// incorrect axis (and therefore do not reproduce the failure), produce
    /// candidates that are mostly filtered by a precondition, or produce the
    /// same values repeatedly.
    ///
    /// - Note: This is reported using `OSLog`.
    public static let shrinking     = PropertyDiagnostics(rawValue: 1 << 3)
    
    /// Report all diagnostics.
    public static let all: PropertyDiagnostics =
    [
        .original,
        .verbose,
        .slowness,
        .shrinking
    ]
    
    
    
    /// Initializes a ``PropertyDiagnostics`` instance from the given raw value.
    /// - Parameter rawValue: The raw value to use.
    public init(
        rawValue: Int
    )
    {
        self.rawValue = rawValue
    }
}



// MARK: - CommandStatistics

/// The options for reporting command statistics in stateful
/// property-based tests.
public struct CommandStatistics: OptionSet, Equatable, Sendable
{
    /// The raw value.
    public let rawValue: Int
    
    
    
    /// Report per-iteration command distribution.
    ///
    /// Enable this to report the percentage of successful iterations that
    /// contained each command.
    public static let presence          = CommandStatistics(rawValue: 1 << 0)
    
    /// Report aggregate command distribution.
    ///
    /// Enable this to report the distribution of commands across all
    /// iterations.
    public static let frequency         = CommandStatistics(rawValue: 1 << 1)
    
    /// Report command sequence counts.
    ///
    /// Enable this to report the minimum, maximum, and average command
    /// sequence count across all iterations.
    public static let sequenceCount     = CommandStatistics(rawValue: 1 << 2)
    
    /// Report all statistics.
    public static let all: CommandStatistics =
    [
        .presence,
        .frequency,
        .sequenceCount
    ]
    
    
    
    /// Initializes a ``CommandStatistics`` instance from the given raw value.
    /// - Parameter rawValue: The raw value to use.
    public init(
        rawValue: Int
    )
    {
        self.rawValue = rawValue
    }
}
