//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A boolean expression evaluated during macro expression decomposition.
public struct BooleanExpr: Equatable, Sendable
{
    /// The source text of the expression.
    public let text     : String
    
    /// The evaluated boolean value.
    public let value    : Bool
    
    
    
    /// Initializes a ``BooleanExpr`` instance from the given values.
    public init(
        text    : String,
        value   : Bool
    )
    {
        self.text   = text
        self.value  = value
    }
}
