//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros



// MARK: - WeightMacro

package protocol WeightMacro: PeerMacro { }

extension WeightMacro
{
    /// Expands an attached macro to introduce peer declarations that exist
    /// alongside the given declaration.
    /// - Parameters:
    ///   - node: The custom attribute describing the attached macro.
    ///   - declaration: The declaration to which the macro attribute is
    ///   attached.
    ///   - context: The context in which to perform the macro expansion.
    /// - Returns: The set of peer declarations.
    public static func expansion(
        of                  node        : AttributeSyntax,
        providingPeersOf    declaration : some DeclSyntaxProtocol,
        in                  context     : some MacroExpansionContext
    ) throws -> [DeclSyntax]
    {
        guard declaration.is(EnumCaseDeclSyntax.self)
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    WeightDiagnosticKind.requiresEnumCase
            ))
            
            return []
        }
        
        guard
            let args = node.arguments?.as(LabeledExprListSyntax.self),
            let firstArg: LabeledExprSyntax = args.first
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    WeightDiagnosticKind.requiresArgument
            ))
            
            return []
        }
        
        guard let integerLiteral
                = firstArg.expression.as(IntegerLiteralExprSyntax.self)
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    WeightDiagnosticKind.requiresIntegerLiteral
            ))
            
            return []
        }
        
        guard
            let value = Int(integerLiteral.literal.text),
            value > 0
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    WeightDiagnosticKind.requiresPositiveInteger
            ))
            
            return []
        }
        
        return []
    }
}



// MARK: - WeightDiagnosticKind

/// Diagnostics for ``Weight()`` macro expansion.
private enum WeightDiagnosticKind: DiagnosticMessage
{
    /// The macro is not attached to an enum case.
    case requiresEnumCase
    
    /// No argument was provided.
    case requiresArgument
    
    /// The argument is not an integer literal.
    case requiresIntegerLiteral
    
    /// The argument is not a positive integer.
    case requiresPositiveInteger
    
    
    
    /// The diagnostic message.
    var message: String
    {
        switch self
        {
            case .requiresEnumCase:
                
                return "@Weight can only be applied to enum cases"
                
            case .requiresArgument:
                
                return "@Weight requires a weight argument"
                
            case .requiresIntegerLiteral:
                
                return "@Weight requires an integer literal argument"
             
            case .requiresPositiveInteger:
                
                return "@Weight requires a positive integer argument"
        }
    }
    
    
    
    ///The diagnostic message’s type identifier.
    var diagnosticID: MessageID
    {
        let id: String
        
        switch self
        {
            case .requiresEnumCase          : id = "requiresEnumCase"
            case .requiresArgument          : id = "requiresArgument"
            case .requiresIntegerLiteral    : id = "requiresIntegerLiteral"
            case .requiresPositiveInteger   : id = "requiresPositiveInteger"
        }
        
        return MessageID(
            domain:     "swift-test-kit",
            id:         id
        )
    }
    
    
    
    /// The diagnostic severity.
    var severity: DiagnosticSeverity
    {
        return .error
    }
}
