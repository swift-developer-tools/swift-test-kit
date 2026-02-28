//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

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
