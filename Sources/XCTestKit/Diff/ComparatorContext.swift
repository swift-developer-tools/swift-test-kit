//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The context for tracking state across recursive comparison calls.
internal final class ComparatorContext
{
    /// The identifiers of visited expected reference types.
    var visitedExpected : Set<ObjectIdentifier>
    
    /// The identifiers of visited actual reference types.
    var visitedActual   : Set<ObjectIdentifier>
    
    /// The options for computing diffs.
    let options         : XCTKDiffOptions
    
    
    
    /// Initializes a ``ComparatorContext`` instance, optionally specifying
    /// values for its properties.
    init(
        visitedExpected : Set<ObjectIdentifier>     = [],
        visitedActual   : Set<ObjectIdentifier>     = [],
        options         : XCTKDiffOptions           = .init()
    )
    {
        self.visitedExpected    = visitedExpected
        self.visitedActual      = visitedActual
        self.options            = options
    }
}
