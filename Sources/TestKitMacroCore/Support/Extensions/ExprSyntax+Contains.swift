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
    /// Whether the expression or any sub-expressions contain the specified
    /// kind of expression.
    /// - Parameter exprKind: The kind of expression.
    /// - Returns: Whether the expression or any sub-expressions contain the
    /// specified kind of expression.
    internal func contains<T>(
        _ exprKind: T.Type
    ) -> Bool where T : ExprSyntaxProtocol
    {
        if self.is(exprKind)
        {
            return true
        }
        
        for subExpr in self.children(viewMode: .sourceAccurate)
        {
            if
                let expr = subExpr.as(ExprSyntax.self),
                expr.contains(exprKind)
            {
                return true
            }
        }
        
        return false
    }
}
