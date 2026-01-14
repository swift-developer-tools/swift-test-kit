//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

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
