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



// MARK: - StatefulMacro

package protocol StatefulMacro: ExtensionMacro { }

extension StatefulMacro
{
    /// Expands an attached extension macro to produce a set of extensions.
    /// - Parameters:
    ///   - node: The custom attribute describing the attached macro.
    ///   - declaration: The declaration to which the macro attribute is
    ///   attached.
    ///   - type: The type for which to provide extensions.
    ///   - protocols: The list of protocols to which to add conformances.
    ///   These will always be protocols for which the type does not already
    ///   state a conformance.
    ///   - context: The context in which to perform the macro expansion.
    /// - Returns: The set of extension declarations introduced by the macro,
    /// which are always inserted at top-level scope. Each extension must
    /// extend the type parameter.
    package static func expansion(
        of                      node        : AttributeSyntax,
        attachedTo              declaration : some DeclGroupSyntax,
        providingExtensionsOf   type        : some TypeSyntaxProtocol,
        conformingTo            protocols   : [TypeSyntax],
        in                      context     : some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax]
    {
        guard protocols
            .contains(where: { $0.trimmedDescription == "Stateful" })
        else
        {
            return []
        }
        
        
        
        if declaration.is(ClassDeclSyntax.self)
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    StatefulDiagnosticKind.classNotSupported
            ))
            
            return []
        }
        
        if declaration.is(StructDeclSyntax.self)
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    StatefulDiagnosticKind.structNotSupported
            ))
            
            return []
        }
        
        guard declaration.is(EnumDeclSyntax.self)
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    StatefulDiagnosticKind.unsupportedDeclaration
            ))
            
            return []
        }
        
        
        
        let cases: [EnumCase] = declaration.enumCases
        
        if cases.isEmpty
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    StatefulDiagnosticKind.uninhabitedEnum
            ))
            
            return []
        }
        
        
        
        let accessLevel: String = makeAccessPrefix(
            for:    declaration,
            in:     context
        )
        
        let typeName: String = type.trimmedDescription
        
        let typeSyntaxes: [TypeSyntax] = cases.flatMap
        {
            return $0.associatedValues.map { $0.typeSyntax }
        }
        
        let methods: String = makeEnumArbitrary(
            kind:           EnumGenerationKind(cases: cases),
            cases:          cases,
            typeName:       typeName,
            accessLevel:    accessLevel
        )
        + "\n\n"
        + makeEnumShrink(
            cases:          cases,
            typeName:       typeName,
            accessLevel:    accessLevel
        )
        
        
        
        let genericParameterClause: GenericParameterClauseSyntax?
            = declaration.as(EnumDeclSyntax.self)?.genericParameterClause
        
        let whereClause: String = makeWhereClause(
            parameterClause:    genericParameterClause,
            typeSyntaxes:       typeSyntaxes
        )
        
        
        
        let extensionDecl: DeclSyntax =
        """
        extension \(type.trimmed): Stateful\(raw: whereClause)
        {
        \(raw: methods)
        }
        """
        
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
}



// MARK: - StatefulDiagnosticKind

/// Diagnostics for ``Stateful()`` macro expansion.
private enum StatefulDiagnosticKind: DiagnosticMessage
{
    /// Classes are not supported.
    case classNotSupported
    
    /// Structs are not supported.
    case structNotSupported
    
    /// Uninhabited enums are not supported.
    case uninhabitedEnum
    
    /// An unsupported declaration kind.
    case unsupportedDeclaration
    
    
    
    /// The diagnostic message.
    var message: String
    {
        switch self
        {
            case .classNotSupported:
                
                return "@Stateful cannot be applied to classes"
                
            case .structNotSupported:
                
                return "@Stateful cannot be applied to structs"
                
            case .uninhabitedEnum:
                
                return "@Stateful cannot be applied to enums with no cases"
             
            case .unsupportedDeclaration:
                
                return "@Stateful can only be applied to enums"
        }
    }
    
    
    
    ///The diagnostic message’s type identifier.
    var diagnosticID: MessageID
    {
        let id: String
        
        switch self
        {
            case .classNotSupported         : id = "classNotSupported"
            case .structNotSupported        : id = "structNotSupported"
            case .uninhabitedEnum           : id = "uninhabitedEnum"
            case .unsupportedDeclaration    : id = "unsupportedDeclaration"
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
