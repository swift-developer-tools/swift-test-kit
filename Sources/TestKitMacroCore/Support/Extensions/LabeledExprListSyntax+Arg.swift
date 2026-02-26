//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



extension LabeledExprListSyntax
{
    /// Gets the specified argument.
    /// - Parameter label: The label of the argument to retrieve.
    /// - Returns: The specified argument, or `nil` if not found.
    internal func getArg(
        labeled label: String,
    ) -> ExprSyntax?
    {
        for arg in self
        {
            if arg.label?.text == label
            {
                return arg.expression
            }
        }
        
        return nil
    }
    
    
    
    /// Unlabeled arguments.
    internal var positionalArgs: [ExprSyntax]
    {
        var args: [ExprSyntax] = []
        
        for arg in self
        {
            if arg.label == nil
            {
                args.append(arg.expression)
            }
        }
        
        return args
    }
}
