//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



public extension TKBooleanExpr
{
    /// Initializes a ``TKBooleanExpr`` instance from the given values.
    ///
    /// - Note: This convenience initializer is available only in the test
    /// target. Production code uses the labeled memberwise initializer to
    /// ensure correctness in generated macro expansion code.
    ///
    /// - Parameters:
    ///   - text: The source text of the expression.
    ///   - value: The evaluated boolean value.
    init(
        _ text  : String,
        _ value : Bool
    )
    {
        self.init(
            text:   text,
            value:  value
        )
    }
}
