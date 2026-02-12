//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The context for tracking state across recursive formatting calls.
internal final class FormatterContext
{
    /// The formatted diff lines.
    ///
    /// The default value is an empty array.
    internal var lines              : [FormattedLine]
    
    /// The current path being traversed.
    ///
    /// The default value is an empty array.
    internal var currentPath        : [DiffNodeLabel]
    
    /// The current indentation level.
    ///
    /// The default value is `0`.
    internal var currentIndent      : Int
    
    /// The number of emitted diffs.
    ///
    /// The default value is `0`.
    internal var emittedDiffCount   : Int
    
    /// The total number of diffs in the diff tree.
    internal var totalDiffCount     : Int?
    
    /// Whether the output was truncated.
    ///
    /// The default value is `false`.
    internal var isTruncated        : Bool
    
    /// The options for formatting diffs.
    ///
    /// The default value is a default-initialized ``FormatOptions`` instance.
    internal var options            : FormatOptions
    
    
    
    /// Initializes a ``FormatterContext`` instance from the given diff node,
    /// optionally specifying values for its properties.
    internal init(
        node                : DiffNode,
        lines               : [FormattedLine]   = [],
        currentPath         : [DiffNodeLabel]   = [],
        currentIndent       : Int               = 0,
        emittedDiffCount    : Int               = 0,
        isTruncated         : Bool              = false,
        options             : FormatOptions     = .init()
    )
    {
        self.lines              = lines
        self.currentPath        = currentPath
        self.currentIndent      = currentIndent
        self.emittedDiffCount   = emittedDiffCount
        self.isTruncated        = isTruncated
        self.options            = options
        
        self.totalDiffCount = options.countDiffs
            ? Self.countDiffs(in: node)
            : nil
    }
    
    
    
    /// Initializes a ``FormatterContext`` instance from the given values.
    internal init(
        options         : FormatOptions,
        totalDiffCount  : Int?          = nil
    )
    {
        self.lines              = []
        self.currentPath        = []
        self.currentIndent      = 0
        self.emittedDiffCount   = 0
        self.isTruncated        = false
        self.options            = options
        self.totalDiffCount     = totalDiffCount
    }
    
    
    
    /// Whether the maximum number of diffs has been reached.
    internal var isAtMaxDiffs: Bool
    {
        guard let maxDiffs: Int = options.maxDiffs
        else
        {
            return false
        }
        
        return emittedDiffCount >= maxDiffs
    }
    
    
    
    /// Counts the number of diffs in the given node.
    ///
    /// Diffs are counted according to how the formatter interprets the diff
    /// tree. For example, a line diff with five character changes counts as
    /// a single diff, since the formatter emits only one line with an inline
    /// character summary. On the other hand, a struct diff with three property
    /// differences counts as three diffs, since each is emitted individually.
    ///
    /// - Parameter node: The node to use.
    /// - Returns: The numebr of diffs in the given node.
    private static func countDiffs(
        in node: DiffNode
    ) -> Int
    {
        switch node.kind
        {
            case .same:
                
                return 0
                
            case
                .cycle,
                .missing,
                .unexpected:
            
                return 1
                
            case let .different(_, _, tree):
                
                if
                    tree.isEmpty
                    || node.label.isLine
                {
                    return 1
                }
                
                if tree.isSetTree
                {
                    return tree.count
                }
                
                return tree.reduce(0) { $0 + countDiffs(in: $1) }
        }
    }
}
