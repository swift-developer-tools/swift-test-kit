//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The context for tracking state across recursive comparison calls.
internal final class ComparatorContext
{
    /// The identifiers of visited expected reference types.
    internal var visitedExpected    : Set<ObjectIdentifier>
    
    /// The identifiers of visited actual reference types.
    internal var visitedActual      : Set<ObjectIdentifier>
    
    /// The options for computing diffs.
    internal let options            : DiffOptions
    
    
    
    /// Initializes a ``ComparatorContext`` instance, optionally specifying
    /// values for its properties.
    internal init(
        visitedExpected : Set<ObjectIdentifier>     = [],
        visitedActual   : Set<ObjectIdentifier>     = [],
        options         : DiffOptions               = .init()
    )
    {
        self.visitedExpected    = visitedExpected
        self.visitedActual      = visitedActual
        self.options            = options
    }
}
