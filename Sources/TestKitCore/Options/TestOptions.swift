//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - TestOptions

/// The options for testing.
public struct TestOptions: Equatable, Sendable
{
    /// Whether to compute and display diffs on assertion failure.
    ///
    /// The default value is `true`.
    public var diffEnabled      : Bool
    
    /// The options for computing diffs.
    ///
    /// The default value is a default-initialized ``DiffOptions`` instance.
    public var diffOptions      : DiffOptions
    
    /// The options for formatting diffs.
    ///
    /// The default value is a default-initialized ``FormatOptions`` instance.
    public var formatOptions    : FormatOptions
    
    /// The options for property-based testing.
    ///
    /// The default value is a default-initialized ``PropertyOptions``
    /// instance.
    public var propertyOptions  : PropertyOptions
    
    
    
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its properties.
    public init(
        diffEnabled     : Bool              = true,
        diffOptions     : DiffOptions       = .init(),
        formatOptions   : FormatOptions     = .init(),
        propertyOptions : PropertyOptions   = .init()
    )
    {
        self.diffEnabled        = diffEnabled
        self.diffOptions        = diffOptions
        self.formatOptions      = formatOptions
        self.propertyOptions    = propertyOptions
    }
}



// MARK: - DiffOptions

/// The options for computing diffs.
public struct DiffOptions: Equatable, Sendable
{
    /// The maximum recursion depth when computing diffs.
    ///
    /// The default value is `20`. Pass `nil` to disable the depth limit.
    ///
    /// Deeply-nested data structures are compared level by level. When this
    /// depth is reached, the remaining values are compared by their string
    /// representation rather than their internal structure.
    ///
    /// - Warning: Disabling the depth limit may impact performance.
    public var maxRecursionDepth        : Int?
    
    /// The threshold for collapsing character-level diffs.
    ///
    /// The default value is `nil`. Pass `nil` to disable collapsing.
    ///
    /// When comparing strings, if the percentage of changed characters exceeds
    /// this threshold, a string-to-string diff is performed instead of a
    /// character-by-character diff. For example, a threshold of `0.75` would
    /// collapse diffs where more than 75% of characters changed.
    ///
    /// This is useful for avoiding noisy diff output when comparing unrelated
    /// or significantly different strings, while preserving granular diffs for
    /// typos and small changes.
    ///
    /// Consider the situation in which the expected string `"12345"` is
    /// compared to the actual string `"54321"`. 80% of the characters are
    /// considered to have changed, since only one of the five expected
    /// characters (`"5"`) is present and in the correct position.
    ///
    /// If collapsing is disabled, a character-by-character diff is performed.
    /// Specifically, the diff would report the following:
    /// - The leading `"1234"` in the expected string is missing.
    /// - The `"5"` in the expected string is present and unchanged.
    /// - The actual string has an unexpected trailing `"4321"`.
    ///
    /// On the other hand, if collapsing is enabled and set to 75%, a
    /// string-to-string diff is performed instead, since 80% exceeds the
    /// threshold. The diff would simply indicate that the expected string
    /// `"12345"` is not equal to the actual string `"54321"`.
    public var characterDiffThreshold   : Double?
    
    
    
    /// Initializes a ``DiffOptions`` instance, optionally specifying values
    /// for its properties.
    ///
    /// - Precondition: `maxRecursionDepth` must be positive or `nil`.
    /// - Precondition: `characterDiffThreshold` must be must be in the
    /// range `0.0...1.0` or `nil`.
    public init(
        maxRecursionDepth       : Int?      = 20,
        characterDiffThreshold  : Double?   = nil
    )
    {
        precondition(
            maxRecursionDepth == nil
            || maxRecursionDepth! >= 1,
            "maxRecursionDepth must be positive or nil"
        )
        
        precondition(
            characterDiffThreshold == nil
            || (
                characterDiffThreshold! >= 0.0
                && characterDiffThreshold! <= 1.0
            ),
            "characterDiffThreshold must be in the range 0.0...1.0 or nil"
        )
        
        self.maxRecursionDepth          = maxRecursionDepth
        self.characterDiffThreshold     = characterDiffThreshold
    }
}



// MARK: - FormatOptions

/// The options for formatting assertion failures.
public struct FormatOptions: Equatable, Sendable
{
    /// The number of spaces used for each indent.
    ///
    /// The default value is `4`.
    public var indentationSpaces        : Int
    
    /// The maximum number of characters per line, before the line is truncated.
    ///
    /// The default value is `80`.
    public var maxLineLength            : Int
    
    /// The maximum number of diffs shown, before truncating the output.
    ///
    /// The default value is `nil`. Pass `nil` to show all diffs.
    public var maxDiffs                 : Int?
    
    /// Whether to count the total number of diffs to display when output
    /// is truncated by ``maxDiffs``.
    ///
    /// The default value is `false`.
    ///
    /// When `true`, the truncation message shows the exact remaining count
    /// (for example, "... and 5 more differences"). When `false`, it shows
    /// only the limit (for example, "... and more differences (limit: 10)").
    ///
    /// - Note: Enabling this requires traversing the entire diff tree, which
    /// may impact performance for large diffs.
    public var countDiffs               : Bool
    
    /// Whether to show all evaluated expressions, or only those that failed.
    ///
    /// The default value is `true`. Pass `false` to to show only expressions
    /// that contributed to failing the assertion.
    ///
    /// - Note: This option is only applicable to macro assertions.
    public var showAllEvaluated         : Bool
    
    /// Whether to show the count of expressions not evaluated due to
    /// short-circuit evaluation.
    ///
    /// The default value is `true`.
    ///
    /// - Note: This option is only applicable to macro assertions.
    public var showNotEvaluatedCount    : Bool
    
    
    
    /// Initializes a ``FormatOptions`` instance, optionally specifying values
    /// for its properties.
    ///
    /// - Precondition: `indentationSpaces` must be non-negative.
    /// - Precondition: `maxLineLength` must be positive.
    /// - Precondition: `maxDiffs` must be positive or `nil`.
    public init(
        indentationSpaces       : Int   = 4,
        maxLineLength           : Int   = 80,
        maxDiffs                : Int?  = nil,
        countDiffs              : Bool  = false,
        showAllEvaluated        : Bool  = true,
        showNotEvaluatedCount   : Bool  = true
    )
    {
        precondition(
            indentationSpaces >= 0,
            "indentationSpaces must be non-negative"
        )
        
        precondition(
            maxLineLength >= 1,
            "maxLineLength must be positive"
        )
        
        precondition(
            maxDiffs == nil
            || maxDiffs! >= 1,
            "maxDiffs must be positive or nil"
        )
        
        self.indentationSpaces      = indentationSpaces
        self.maxLineLength          = maxLineLength
        self.maxDiffs               = maxDiffs
        self.countDiffs             = countDiffs
        self.showAllEvaluated       = showAllEvaluated
        self.showNotEvaluatedCount  = showNotEvaluatedCount
    }
}



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
    /// `maxDiscardRatio`, and `maxCommandCount` must all be non-negative.
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
            "iterations must be non-negative"
        )
        
        precondition(
            maxShrinkSteps >= 0,
            "maxShrinkSteps must be non-negative"
        )
        
        precondition(
            maxSize >= 0,
            "maxSize must be non-negative"
        )
        
        precondition(
            maxDiscardRatio >= 0,
            "maxDiscardRatio must be non-negative"
        )
        
        precondition(
            maxCommandCount >= 0,
            "maxCommandCount must be non-negative"
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
