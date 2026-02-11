//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxMacros



extension ExprSyntax
{
    /// Creates `nil` literal expression.
    /// - Returns: The `nil` literal expression.
    package static func makeNilLiteral() -> ExprSyntax
    {
        return ExprSyntax(NilLiteralExprSyntax())
    }
    
    
    
    /// Creates a string literal expression from the given content.
    /// - Parameter content: The string literal content.
    /// - Returns: The string literal expression.
    package static func makeStringLiteral(
        _ content: String
    ) -> ExprSyntax
    {
        return ExprSyntax(StringLiteralExprSyntax(content: content))
    }
}
