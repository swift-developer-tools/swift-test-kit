//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - XCTKDiffOptions

/// The options for computing diffs.
public struct XCTKDiffOptions: Equatable, Sendable
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
    public var maxRecursionDepth    : Int?
    
    /// Whether to collapse equal trees when computing diffs.
    ///
    /// The default value is `true`.
    ///
    /// When enabled, the diff computation stops recursing once it determines
    /// that two subtrees are equal, improving performance on large structures
    /// with localized changes.
    ///
    /// - Warning: Disabling tree-collapsing may impact performance.
    public var collapseEqualTrees   : Bool
    
    
    
    /// Initializes an ``XCTKDiffOptions`` instance, optionally specifying
    /// values for its properties.
    public init(
        maxRecursionDepth   : Int?  = 20,
        collapseEqualTrees  : Bool  = true
    )
    {
        precondition(
            maxRecursionDepth == nil
            || maxRecursionDepth! >= 1,
            "maxRecursionDepth must be positive or nil"
        )
        
        self.maxRecursionDepth      = maxRecursionDepth
        self.collapseEqualTrees     = collapseEqualTrees
    }
}



// MARK: - XCTKPrintOptions

/// The options for printing diffs.
public struct XCTKPrintOptions: Equatable, Sendable
{
    /// The number of lines of context shown around each change in diff output.
    ///
    /// The default value is `3`. Pass `0` to show only the changed lines.
    public var contextLines         : Int
    
    /// The number of spaces used for each indent.
    ///
    /// The default value is `4`.
    public var indentationSpaces    : Int
    
    /// The maximum number of characters per line, before the line is truncated.
    ///
    /// The default value is `80`.
    public var maxLineLength        : Int
    
    /// Whether to show type annotations.
    ///
    /// The default value is `true`.
    public var showTypeAnnotations  : Bool
    
    /// The maximum number of diffs shown, before truncating the output.
    ///
    /// The default value is `nil`. Pass `nil` to show all diffs.
    public var maxDiffs             : Int?
    
    /// The maximum number of diff lines shown, before truncating the output.
    ///
    /// The default value is `nil`. Pass `nil` to show all diff lines.
    public var maxDiffLines         : Int?
    
    /// The character to use in a diff to indicate the expected value.
    ///
    /// The default value is `+`.
    public var expectedSymbol       : Character
    
    /// The character to use in a diff to indicate the actual value.
    ///
    /// The default value is `-`.
    public var actualSymbol         : Character
    
    
    
    /// Initializes an ``XCTKPrintOptions`` instance, optionally specifying
    /// values for its properties.
    public init(
        contextLines        : Int           = 3,
        indentationSpaces   : Int           = 4,
        maxLineLength       : Int           = 80,
        showTypeAnnotations : Bool          = true,
        maxDiffs            : Int?          = nil,
        maxDiffLines        : Int?          = nil,
        expectedSymbol      : Character     = .init("+"),
        actualSymbol        : Character     = .init("-")
    )
    {
        precondition(
            contextLines >= 0,
            "contextLines must be non-negative"
        )
        
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
        
        precondition(
            maxDiffLines == nil
            || maxDiffLines! >= 1,
            "maxDiffLines must be positive or nil"
        )
        
        self.contextLines           = contextLines
        self.indentationSpaces      = indentationSpaces
        self.maxLineLength          = maxLineLength
        self.showTypeAnnotations    = showTypeAnnotations
        self.maxDiffs               = maxDiffs
        self.maxDiffLines           = maxDiffLines
        self.expectedSymbol         = expectedSymbol
        self.actualSymbol           = actualSymbol
    }
}
