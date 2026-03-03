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
    ///
    /// - Warning: Very large `maxSize` values can cause significant memory
    /// pressure, especially for collection types, which generate up to
    /// `maxSize` elements per iteration.
    public init(
        iterations      : Int                   = 100,
        maxShrinkSteps  : Int                   = 100,
        maxSize         : Int                   = 100,
        maxDiscardRatio : Int                   = 10,
        maxCommandCount : Int                   = 100,
        statistics      : CommandStatistics     = [],
        seed            : UInt64?               = nil
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
        
        self.iterations         = iterations
        self.maxShrinkSteps     = maxShrinkSteps
        self.maxSize            = maxSize
        self.maxDiscardRatio    = maxDiscardRatio
        self.maxCommandCount    = maxCommandCount
        self.statistics         = statistics
        self.seed               = seed
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
    ///
    /// Enable this to report ``presence``, ``frequency``, and ``sequenceCount``
    /// statistics.
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
