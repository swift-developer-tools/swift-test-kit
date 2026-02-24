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



// MARK: - ArbitraryMacro

package protocol ArbitraryMacro: ExtensionMacro { }

extension ArbitraryMacro
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
            .contains(where: { $0.trimmedDescription == "Arbitrary" })
        else
        {
            return []
        }
        
        
        
        if declaration.is(ClassDeclSyntax.self)
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    ArbitraryDiagnosticKind.classNotSupported
            ))
            
            return []
        }
        
        guard
            declaration.is(StructDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
        else
        {
            context.diagnose(Diagnostic(
                node:       node,
                message:    ArbitraryDiagnosticKind.unsupportedDeclaration
            ))
            
            return []
        }
        
        
        
        let accessLevel: String = makeAccessPrefix(
            for:    declaration,
            in:     context
        )
        
        let typeName        : String        = type.trimmedDescription
        let typeSyntaxes    : [TypeSyntax]
        let methods         : String
        
        if declaration.is(EnumDeclSyntax.self)
        {
            let cases: [EnumCase] = declaration.enumCases
            
            if cases.isEmpty
            {
                context.diagnose(Diagnostic(
                    node:       node,
                    message:    ArbitraryDiagnosticKind.uninhabitedEnum
                ))
                
                return []
            }
            
            typeSyntaxes = cases.flatMap
            {
                return $0.associatedValues.map { $0.typeSyntax}
            }
            
            methods = makeEnumArbitrary(
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
        }
        else
        {
            let result: StoredProperties = declaration.storedProperties
            
            if !result.missingAnnotations.isEmpty
            {
                for name in result.missingAnnotations
                {
                    context.diagnose(Diagnostic(
                        node:       node,
                        message:    ArbitraryDiagnosticKind
                            .missingTypeAnnotation(typeName: name)
                    ))
                }
                
                return []
            }
            
            typeSyntaxes = result.properties.map { $0.typeSyntax }
            
            methods = makeStructArbitrary(
                properties:     result.properties,
                typeName:       typeName,
                accessLevel:    accessLevel
            )
            + "\n\n"
            + makeStructShrink(
                properties:     result.properties,
                typeName:       typeName,
                accessLevel:    accessLevel
            )
        }
        
        
        
        let genericParameterClause: GenericParameterClauseSyntax?
        
        if let enumDecl = declaration.as(EnumDeclSyntax.self)
        {
            genericParameterClause = enumDecl.genericParameterClause
        }
        else if let structDecl = declaration.as(StructDeclSyntax.self)
        {
            genericParameterClause = structDecl.genericParameterClause
        }
        else
        {
            genericParameterClause = nil
        }
        
        let whereClause: String = makeWhereClause(
            parameterClause:    genericParameterClause,
            typeSyntaxes:       typeSyntaxes
        )
        
        
        
        let extensionDecl: DeclSyntax =
        """
        extension \(type.trimmed): Arbitrary\(raw: whereClause)
        {
        \(raw: methods)
        }
        """
        
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
    
    
    
    // MARK: Struct generation
    
    /// Generates the ``Arbitrary/arbitrary(using:)`` method for a struct.
    /// - Parameters:
    ///   - properties: The stored properties.
    ///   - typeName: The struct name.
    ///   - accessLevel: The access level.
    /// - Returns: The method expansion.
    private static func makeStructArbitrary(
        properties  : [StoredProperty],
        typeName    : String,
        accessLevel : String
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(indent(1, "\(accessLevel)static func arbitrary("))
        lines.append(indent(2, "using context: GenerationContext"))
        lines.append(indent(1, ") -> \(typeName)"))
        lines.append(indent(1, "{"))
        
        let initProperties: [StoredProperty]
            = properties.filter { !$0.isImmutableWithDefault }
        
        if initProperties.isEmpty
        {
            lines.append(indent(2, "return \(typeName)()"))
        }
        else
        {
            lines.append(indent(2, "return \(typeName)("))
            
            for (index, property) in initProperties.enumerated()
            {
                let trailing: String = index < initProperties.count - 1
                    ? ","
                    : ""
                
                let text: String = "\(property.name): \(property.typeName)"
                    + ".arbitrary(using: context)\(trailing)"
                
                lines.append(indent(3, text))
            }
            
            lines.append(indent(2, ")"))
        }
        
        lines.append(indent(1, "}"))
        
        return lines.joined(separator: "\n")
    }
    
    
    
    // MARK: Struct shrinking
    
    /// Generates the ``Arbitrary/shrink()`` method for a struct.
    /// - Parameters:
    ///   - properties: The stored properties.
    ///   - typeName: The struct name.
    ///   - accessLevel: The access level.
    /// - Returns: The method expansion.
    private static func makeStructShrink(
        properties  : [StoredProperty],
        typeName    : String,
        accessLevel : String
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(indent(1, "\(accessLevel)func shrink() -> [\(typeName)]"))
        lines.append(indent(1, "{"))
        
        let initProperties: [StoredProperty]
            = properties.filter { !$0.isImmutableWithDefault }
        
        if initProperties.isEmpty
        {
            lines.append(indent(2, "return []"))
        }
        else
        {
            lines.append(indent(2, "var _$results: [\(typeName)] = []"))
            
            let initArgs: String = initProperties
                .map { "\($0.name): \($0.name)" }
                .joined(separator: ", ")
            
            for property in initProperties
            {
                lines.append("")
                
                let text1: String
                    = "for \(property.name) in \(property.name).shrink()"
                
                lines.append(indent(2, text1))
                lines.append(indent(2, "{"))
                
                let text2: String
                    = "_$results.append(\(typeName)(\(initArgs)))"
                
                lines.append(indent(3, text2))
                lines.append(indent(2, "}"))
            }
            
            lines.append("")
            lines.append(indent(2, "return _$results"))
        }
        
        lines.append(indent(1, "}"))
        
        return lines.joined(separator: "\n")
    }
}



// MARK: - ArbitraryDiagnosticKind

/// Diagnostics for ``Arbitrary()`` macro expansion.
private enum ArbitraryDiagnosticKind: DiagnosticMessage
{
    /// Classes are not supported.
    case classNotSupported
    
    /// Uninhabited enums are not supported.
    case uninhabitedEnum
    
    /// Properties with missing type annotations are not supported.
    case missingTypeAnnotation(typeName: String)
    
    /// An unsupported declaration kind.
    case unsupportedDeclaration
    
    
    
    /// The diagnostic message.
    var message: String
    {
        switch self
        {
            case .classNotSupported:
                
                return "@Arbitrary cannot be applied to classes"
                
            case .uninhabitedEnum:
                
                return "@Arbitrary cannot be applied to enums with no cases"
                
            case .missingTypeAnnotation:
                
                return "@Arbitrary requires an explicit type annotation"
                
            case .unsupportedDeclaration:
                
                return "@Arbitrary can only be applied to structs and enums"
        }
    }
    
    
    
    ///The diagnostic message’s type identifier.
    var diagnosticID: MessageID
    {
        let id: String
        
        switch self
        {
            case .classNotSupported         : id = "classNotSupported"
            case .uninhabitedEnum           : id = "uninhabitedEnum"
            case .missingTypeAnnotation     : id = "missingTypeAnnotation"
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
