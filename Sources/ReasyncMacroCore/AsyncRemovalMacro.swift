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



// MARK: - AsyncRemovalMacro

package protocol AsyncRemovalMacro: PeerMacro { }

extension AsyncRemovalMacro
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
        guard var function = declaration.as(FunctionDeclSyntax.self)
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    AsyncRemovalDiagnosticKind.requiresFunction
            ))
            
            return []
        }
        
        guard function.signature.effectSpecifiers?.asyncSpecifier != nil
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    AsyncRemovalDiagnosticKind.requiresAsync
            ))
            
            return []
        }
        
        
        
        if let reasyncAttrIndex: AttributeListSyntax.Index
            = function.reasyncAttrIndex
        {
            let reasyncAttr: AttributeListSyntax.Element
                = function.attributes[reasyncAttrIndex]
            
            /// Remove the attribute from the peer declaration.
            function.attributes.remove(at: reasyncAttrIndex)
            
            /// Transfer the leading trivia from the removed attribute
            /// to the first remaining attribute, the access level modifier,
            /// or to `func`.
            if var first: AttributeListSyntax.Element
                = function.attributes.first
            {
                first.leadingTrivia = reasyncAttr.leadingTrivia
                
                function.attributes[function.attributes.startIndex] = first
            }
            else if var first: DeclModifierSyntax = function.modifiers.first
            {
                first.leadingTrivia = reasyncAttr.leadingTrivia
                
                function.modifiers[function.modifiers.startIndex] = first
            }
            else
            {
                function.funcKeyword.leadingTrivia = reasyncAttr.leadingTrivia
            }
        }
        
        
        
        let rewriter = AsyncRemovalRewriter()
        
        let rewritten: FunctionDeclSyntax
            = rewriter.rewrite(function).cast(FunctionDeclSyntax.self)
        
        return [DeclSyntax(rewritten)]
    }
}



// MARK: - AsyncRemovalDiagnosticKind

/// Diagnostics for ``Reasync()`` macro expansion.
private enum AsyncRemovalDiagnosticKind: DiagnosticMessage
{
    /// Non-function declarations are not supported.
    case requiresFunction
    
    /// Synchronous function declarations are not supported.
    case requiresAsync
    
    
    
    /// The diagnostic message.
    var message: String
    {
        switch self
        {
            case .requiresFunction:
                
                return "@Reasync can only be applied to functions"
                
            case .requiresAsync:
                
                return "@Reasync can only be applied to async functions"
        }
    }
    
    
    
    ///The diagnostic message’s type identifier.
    var diagnosticID: MessageID
    {
        let id: String
        
        switch self
        {
            case .requiresFunction  : id = "requiresFunction"
            case .requiresAsync     : id = "requiresAsync"
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

