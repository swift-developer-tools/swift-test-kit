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



// MARK: - ArbitraryExtensionMacro

package protocol ArbitraryExtensionMacro: ExtensionMacro { }

extension ArbitraryExtensionMacro
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
    
    
    
    // MARK: Enum generation
    
    /// Generates the ``Arbitrary/arbitrary(using:)`` method for an enum.
    /// - Parameters:
    ///   - cases: The enum cases.
    ///   - typeName: The enum name.
    ///   - accessLevel: The access level.
    /// - Returns: The method expansion.
    private static func makeEnumArbitrary(
        cases       : [EnumCase],
        typeName    : String,
        accessLevel : String
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(indent(1, "\(accessLevel)static func arbitrary("))
        lines.append(indent(2, "using context: GenerationContext"))
        lines.append(indent(1, ") -> \(typeName)"))
        lines.append(indent(1, "{"))
        
        if cases.count == 1
        {
            lines.append(indent(2, "return \(makeCaseConstruction(cases[0]))"))
        }
        else
        {
            let text1: String = "switch context.random(in: 0..<\(cases.count))"
            
            lines.append(indent(2, text1))
            lines.append(indent(2, "{"))
            
            for (index, enumCase) in cases.enumerated()
            {
                let pattern: String = index < cases.count - 1
                    ? "case \(index):"
                    : "default:"
                
                lines.append(indent(3, pattern))
                
                let text2: String = "return \(makeCaseConstruction(enumCase))"
                
                lines.append(indent(4, text2))
                
                if index < cases.count - 1
                {
                    lines.append("")
                }
            }
            
            lines.append(indent(2, "}"))
        }
        
        lines.append(indent(1, "}"))
        
        return lines.joined(separator: "\n")
    }
    
    
    
    // MARK: Enum shrinking
    
    /// Generates the ``Arbitrary/shrink()`` method for an enum.
    /// - Parameters:
    ///   - cases: The enum cases.
    ///   - typeName: The enum name.
    ///   - accessLevel: The access level.
    /// - Returns: The method expansion.
    private static func makeEnumShrink(
        cases       : [EnumCase],
        typeName    : String,
        accessLevel : String
    ) -> String
    {
        var lines: [String] = []
        
        lines.append(indent(1, "\(accessLevel)func shrink() -> [\(typeName)]"))
        lines.append(indent(1, "{"))
        
        let hasAssociatedValues: Bool = cases.contains
        {
            return !$0.associatedValues.isEmpty
        }
        
        if !hasAssociatedValues
        {
            lines.append(indent(2, "return []"))
            lines.append(indent(1, "}"))
            
            return lines.joined(separator: "\n")
        }
        
        lines.append(indent(2, "switch self"))
        lines.append(indent(2, "{"))
        
        for (caseIndex, enumCase) in cases.enumerated()
        {
            if enumCase.associatedValues.isEmpty
            {
                lines.append(indent(3, "case .\(enumCase.name):"))
                lines.append("")
                lines.append(indent(4, "return []"))
            }
            else
            {
                let bindings: [String] = makeBindingNames(
                    for: enumCase.associatedValues
                )
                
                let patternArgs: String = bindings.joined(separator: ", ")
                
                let reconstructionArgs: String = makeReconstructionArgs(
                    for:        enumCase.associatedValues,
                    bindings:   bindings
                )
                
                let text1: String
                    = "case let .\(enumCase.name)(\(patternArgs)):"
                
                lines.append(indent(3, text1))
                lines.append("")
                lines.append(indent(4, "var _$results: [\(typeName)] = []"))
                
                for (valueIndex, _) in enumCase.associatedValues.enumerated()
                {
                    let binding: String = bindings[valueIndex]
                    
                    lines.append("")
                    
                    let text2: String = "for \(binding) in \(binding).shrink()"
                    
                    lines.append(indent(4, text2))
                    lines.append(indent(4, "{"))
                    
                    let text3: String = "_$results.append(.\(enumCase.name)"
                        + "(\(reconstructionArgs)))"
                    
                    lines.append(indent(5, text3))
                    lines.append(indent(4, "}"))
                }
                
                lines.append("")
                lines.append(indent(4, "return _$results"))
            }
            
            if caseIndex < cases.count - 1
            {
                lines.append("")
            }
        }
        
        lines.append(indent(2, "}"))
        lines.append(indent(1, "}"))
        
        return lines.joined(separator: "\n")
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
    
    
    
    // MARK: Support
    
    /// Indents the given text by the given amount.
    /// - Parameters:
    ///   - level: The amount by which to indent the given text.
    ///   - text: The text to indent.
    /// - Returns: The indented text.
    private static func indent(
        _ level : Int,
        _ text  : String
    ) -> String
    {
        return String(repeating: "    ", count: level) + text
    }
    
    
    
    /// Creates a prefix string representing the effective access level of
    /// the given declaration.
    ///
    /// The effective access level of a declaration is the most restrictive
    /// access level of the declaration or any enclosing type.
    ///
    /// - Parameters:
    ///   - decl: The declaration.
    ///   - context: The context in which the declaration appears.
    /// - Returns: The prefix string representing the effective access level
    /// of the given declaration.
    private static func makeAccessPrefix(
        for     decl    : some DeclGroupSyntax,
        in      context : some MacroExpansionContext
    ) -> String
    {
        var accessLevel: String? = decl.accessLevel
        
        for enclosing in context.lexicalContext
        {
            let enclosingLevel: String?
            
            if let declaration = enclosing.as(ClassDeclSyntax.self)
            {
                enclosingLevel = declaration.accessLevel
            }
            else if let declaration = enclosing.as(EnumDeclSyntax.self)
            {
                enclosingLevel = declaration.accessLevel
            }
            else if let declaration = enclosing.as(StructDeclSyntax.self)
            {
                enclosingLevel = declaration.accessLevel
            }
            else
            {
                continue
            }
            
            accessLevel = moreRestrictive(accessLevel, enclosingLevel)
        }
        
        switch accessLevel
        {
            case "public"       : return "public "
            case "package"      : return "package "
            case "private"      : return "fileprivate "
            case "fileprivate"  : return "fileprivate "
            default             : return "internal "
        }
    }
    
    
    
    /// Returns the more restrictive of the given access levels.
    /// - Parameters:
    ///   - lhs: The first access level.
    ///   - rhs: The second access level.
    /// - Returns: The more restrictive of the given access levels.
    private static func moreRestrictive(
        _   lhs : String?,
        _   rhs : String?
    ) -> String?
    {
        func rank(
            _ level: String?
        ) -> Int
        {
            switch level
            {
                case "private"      : return 0
                case "fileprivate"  : return 1
                case "internal"     : return 2
                case "package"      : return 3
                case "public"       : return 4
                default             : return 2
            }
        }
        
        return rank(lhs) <= rank(rhs)
            ? lhs
            : rhs
    }
    
    
    
    /// Creates enum case strings for the given enum case.
    /// - Parameter enumCase: The enum case.
    /// - Returns: The enum case string.
    private static func makeCaseConstruction(
        _ enumCase: EnumCase
    ) -> String
    {
        if enumCase.associatedValues.isEmpty
        {
            return ".\(enumCase.name)"
        }
        
        let args: String = enumCase.associatedValues.map
        {
            value in
            
            let generation: String
                = "\(value.typeName).arbitrary(using: context)"
            
            if let label: String = value.label
            {
                return "\(label): \(generation)"
            }
            
            return generation
        }.joined(separator: ", ")
        
        return ".\(enumCase.name)(\(args))"
    }
    
    
    
    /// Creates binding name strings for the given enum associated values.
    /// - Parameter values: The enum associated values.
    /// - Returns: The binding name strings.
    private static func makeBindingNames(
        for values: [EnumAssociatedValue]
    ) -> [String]
    {
        var unlabeledCounter: Int = 0
        
        return values.map
        {
            value in
            
            if let label: String = value.label
            {
                return label
            }
            
            let name: String = "_$v\(unlabeledCounter)"
            
            unlabeledCounter += 1
            
            return name
        }
    }
    
    
    
    /// Creates reconstruction arguments for the given enum associated values.
    /// - Parameters:
    ///   - values: The enum associated values.
    ///   - bindings: The binding name strings.
    /// - Returns: The reconstruction arguments.
    private static func makeReconstructionArgs(
        for values  : [EnumAssociatedValue],
        bindings    : [String]
    ) -> String
    {
        return zip(values, bindings).map
        {
            (value, binding) in
            
            if let label: String = value.label
            {
                return "\(label): \(binding)"
            }
            
            return binding
        }.joined(separator: ", ")
    }
    
    
    
    /// Creates a `where` clause constraining referenced generic parameters
    /// to ``Arbitrary``.
    /// - Parameters:
    ///   - parameterClause: The generic parameter clause of the declaration.
    ///   - typeSyntaxes: The type syntax nodes to scan for references.
    /// - Returns: The `where` clause string including the leading space, or
    /// an empty string if the declaration has no generic parameters, or none
    /// of the parameters appear in the given type syntax nodes.
    private static func makeWhereClause(
        parameterClause : GenericParameterClauseSyntax?,
        typeSyntaxes    : [TypeSyntax]
    ) -> String
    {
        guard let parameterClause
        else
        {
            return ""
        }
        
        let genericNames: [String] = parameterClause.parameters.map
        {
            return $0.name.text
        }
        
        
        
        let walker = TypeSyntaxWalker()
        
        for typeSyntax in typeSyntaxes
        {
            walker.walk(typeSyntax)
        }
        
        
        
        let referenced: [String] = genericNames.filter
        {
            return walker.identifiers.contains($0)
        }
        
        if referenced.isEmpty
        {
            return ""
        }
        
        
        
        let constraints: String = referenced
            .map { "\($0) : Arbitrary" }
            .joined(separator: ", ")
        
        return " where \(constraints)"
    }
}



// MARK: - ArbitraryDiagnosticKind

/// Diagnostics for ``Arbitrary`` macro expansion.
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
                
                return "@Arbitrary cannot be applied to classes."
                    + " Use a struct or enum instead."
                
            case .uninhabitedEnum:
                
                return "@Arbitrary cannot be applied to enums with no cases."
                
            case let .missingTypeAnnotation(typeName):
                
                return "@Arbitrary requires an explicit type annotation"
                    + " for '\(typeName)'."
                
            case .unsupportedDeclaration:
                
                return "@Arbitrary can only be applied to structs and enums."
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



// MARK: - StoredProperties

/// The stored properties of a declaration, along with any properties
/// that have missing type annotations.
internal struct StoredProperties
{
    /// The stored properties.
    let properties          : [StoredProperty]
    
    /// The names of properties with missing type annotations.
    let missingAnnotations  : [String]
}



/// A stored property of a declaration.
internal struct StoredProperty
{
    /// The name of the property.
    let name        : String
    
    /// The name of the property's type.
    let typeName    : String
    
    /// The syntax node of the property's type.
    let typeSyntax  : TypeSyntax
    
    /// Whether the property is immutable (`let`).
    let isImmutable : Bool
    
    /// Whether the property has a default value.
    let hasDefault  : Bool
    
    
    
    /// Whether the stored property is immutable (`let`) with a default value.
    var isImmutableWithDefault: Bool
    {
        return isImmutable
            && hasDefault
    }
}



// MARK: - EnumCase

/// An enum case.
internal struct EnumCase
{
    /// The name of the case.
    let name                : String
    
    /// The associated values.
    let associatedValues    : [EnumAssociatedValue]
}



/// An associated value of an enum case.
internal struct EnumAssociatedValue
{
    /// The associated value label, if any.
    let label       : String?
    
    /// The name of the associated value's type.
    let typeName    : String
    
    /// The syntax node of the associated value's type.
    let typeSyntax  : TypeSyntax
}
