//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



extension ExprSyntax
{
    /// Whether the expression or any sub-expressions contain a `try`
    /// expression.
    package var containsTry: Bool
    {
        if self.is(TryExprSyntax.self)
        {
            return true
        }
        
        for subExpr in self.children(viewMode: .sourceAccurate)
        {
            if
                let expr = subExpr.as(ExprSyntax.self),
                expr.containsTry
            {
                return true
            }
        }
        
        return false
    }
}
