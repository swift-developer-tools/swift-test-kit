//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - TKOptions

/// The options for testing.
public struct TKOptions: Equatable, Sendable
{
    /// Whether to compute and display diffs on assertion failure.
    ///
    /// The default value is `true`. Pass `false` to delegate to the underlying
    /// XCTest equivalent.
    public var diffEnabled          : Bool
    
    /// Whether tests keep running after an assertion failure.
    ///
    /// The default value is `true`. When `true`, tests keep running after an
    /// assertion fails, equivalent to `#expect` in Swift Testing. When `false`,
    /// failed assertions immediately stop the test, equivalent to `#require`.
    ///
    /// - Note: This option applies only to SwiftTestKit. For XCTestKit, use
    /// [`continueAfterFailure`](https://developer.apple.com/documentation/xctest/xctestcase/continueafterfailure)
    /// on [`XCTKCase`](https://swift-developer-tools.github.io/swift-test-kit/documentation/xctestkit/xctkcase).
    public var continueAfterFailure : Bool
    
    /// The options for computing diffs.
    ///
    /// The default value is a default-initialized ``TKDiffOptions`` instance.
    public var diffOptions          : TKDiffOptions
    
    /// The options for formatting diffs.
    ///
    /// The default value is a default-initialized ``TKFormatOptions`` instance.
    public var formatOptions        : TKFormatOptions
    
    
    
    /// Initializes a ``TKOptions`` instance, optionally specifying values
    /// for its properties.
    public init(
        diffEnabled             : Bool              = true,
        continueAfterFailure    : Bool              = true,
        diffOptions             : TKDiffOptions     = .init(),
        formatOptions           : TKFormatOptions   = .init()
    )
    {
        self.diffEnabled            = diffEnabled
        self.continueAfterFailure   = continueAfterFailure
        self.diffOptions            = diffOptions
        self.formatOptions          = formatOptions
    }
}



// MARK: - TKDiffOptions

/// The options for computing diffs.
public struct TKDiffOptions: Equatable, Sendable
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
    
    
    
    /// Initializes a ``TKDiffOptions`` instance, optionally specifying
    /// values for its properties.
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
            "characterDiffThreshold must be in the range [0.0, 1.0], or nil"
        )
        
        self.maxRecursionDepth          = maxRecursionDepth
        self.characterDiffThreshold     = characterDiffThreshold
    }
}



// MARK: - TKFormatOptions

/// The options for formatting assertion failures.
public struct TKFormatOptions: Equatable, Sendable
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
    
    
    
    /// Initializes a ``TKFormatOptions`` instance, optionally specifying
    /// values for its properties.
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
