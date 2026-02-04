//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



public extension ExprSyntax
{
    /// The kind of logical operator used in the expression, or `nil` if this
    /// is not an infix expression with a logical operator (`&&` or `||`).
    var logicalOperatorKind: BooleanExprWalker.LogicalOperatorKind?
    {
        guard
            let infix       = self.as(InfixOperatorExprSyntax.self),
            let binaryOp    = infix.operator.as(BinaryOperatorExprSyntax.self)
        else
        {
            return nil
        }
        
        return BooleanExprWalker.LogicalOperatorKind(
            text:   binaryOp.operator.text,
            infix:  infix
        )
    }
    
    
    
    /// Whether the expression is an infix expression with a logical operator
    /// (`&&` or `||`).
    var isLogicalBinaryOperation: Bool
    {
        return self.logicalOperatorKind != nil
    }
}
