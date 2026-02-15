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
                    associatedValues:   associatedValues
                )
                
                cases.append(enumCase)
            }
        }
        
        return cases
    }
}
