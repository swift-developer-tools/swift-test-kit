//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



internal extension ExprSyntax
{
    /// The binary operator, or `nil` if the expression is not a recognized
    /// binary operator expression.
    var booleanBinaryOperatorKind: BooleanExprWalker.BinaryOperatorKind?
    {
        guard
            let infix       = self.as(InfixOperatorExprSyntax.self),
            let binaryOp    = infix.operator.as(BinaryOperatorExprSyntax.self)
        else
        {
            return nil
        }
        
        return BooleanExprWalker.BinaryOperatorKind(
            text:   binaryOp.operator.text,
            infix:  infix
        )
    }
    
    
    
    /// Whether the expression is a recognized boolean binary operator
    /// expression.
    var isBooleanBinaryOperator: Bool
    {
        return self.booleanBinaryOperatorKind != nil
    }
}
