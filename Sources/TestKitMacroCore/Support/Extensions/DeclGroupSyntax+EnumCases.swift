//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



extension DeclGroupSyntax
{
    /// The enum cases of the declaration.
    internal var enumCases: [EnumCase]
    {
        var cases: [EnumCase] = []
        
        for member in memberBlock.members
        {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self)
            else
            {
                continue
            }
            
            for element in caseDecl.elements
            {
                var associatedValues: [EnumAssociatedValue] = []
                
                if let parameterClause: EnumCaseParameterClauseSyntax
                    = element.parameterClause
                {
                    for parameter in parameterClause.parameters
                    {
                        let label: String?
                        
                        if
                            let firstName: TokenSyntax = parameter.firstName,
                            firstName.tokenKind != .wildcard
                        {
                            label = firstName.text
                        }
                        else
                        {
                            label = nil
                        }
                        
                        let value = EnumAssociatedValue(
                            label:          label,
                            typeName:       parameter.type.trimmedDescription,
                            typeSyntax:     TypeSyntax(parameter.type)
                        )
                        
                        associatedValues.append(value)
                    }
                }
                
                let enumCase = EnumCase(
                    name:               element.name.text,
                    associatedValues:   associatedValues,
                    weight:             extractWeight(from: caseDecl)
                )
                
                cases.append(enumCase)
            }
        }
        
        return cases
    }
    
    
    
    /// Extracts the ``Weight()`` macro integer literal from the given enum
    /// case declaration, if present.
    /// - Parameter caseDecl: The enum case declaration.
    /// - Returns: The weight, or `nil` if not present.
    private func extractWeight(
        from caseDecl: EnumCaseDeclSyntax
    ) -> Int?
    {
        for attribute in caseDecl.attributes
        {
            guard
                case let .attribute(attr) = attribute,
                let identifier
                    = attr.attributeName.as(IdentifierTypeSyntax.self),
                identifier.name.text == "Weight"
            else
            {
                continue
            }
            
            guard
                let args = attr.arguments?.as(LabeledExprListSyntax.self),
                let firstArg: LabeledExprSyntax = args.first,
                let integerLiteral
                    = firstArg.expression.as(IntegerLiteralExprSyntax.self),
                let value = Int(integerLiteral.literal.text)
            else
            {
                return nil
            }
            
            return value
        }
        
        return nil
    }
}
