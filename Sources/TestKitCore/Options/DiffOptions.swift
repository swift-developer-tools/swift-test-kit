//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The options for computing diffs.
public struct DiffOptions: Equatable, Sendable
{
    /// Whether to compute and display diffs on assertion failure.
    ///
    /// The default value is `true`.
    public var enabled                  : Bool
    
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
        enabled                 : Bool      = true,
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
        
        self.enabled                    = enabled
        self.maxRecursionDepth          = maxRecursionDepth
        self.characterDiffThreshold     = characterDiffThreshold
    }
}
