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
    /// The stored properties of the declaration, along with any properties
    /// that have missing type annotations.
    ///
    /// `class`, `lazy`, `static`, and computed properties are skipped.
    internal var storedProperties: StoredProperties
    {
        var properties          : [StoredProperty]  = []
        var missingAnnotations  : [String]          = []
        
        for member in memberBlock.members
        {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self)
            else
            {
                continue
            }
            
            
            
            let hasExcludedModifier: Bool = varDecl.modifiers.contains
            {
                switch $0.name.tokenKind
                {
                    case
                        .keyword(.class),
                        .keyword(.lazy),
                        .keyword(.static):
                        
                        return true
                        
                    default:
                        
                        return false
                }
            }
            
            if hasExcludedModifier
            {
                continue
            }
            
            
            
            for binding in varDecl.bindings
            {
                if let accessorBlock: AccessorBlockSyntax
                    = binding.accessorBlock
                {
                    /// Skip computed properties (any property with a getter).
                    /// Properties with only `willSet`/`didSet` are stored.
                    switch accessorBlock.accessors
                    {
                        case .getter:
                            
                            continue
                            
                        case let .accessors(list):
                            
                            let hasGetter: Bool = list.contains
                            {
                                return $0.accessorSpecifier.tokenKind
                                    == .keyword(.get)
                            }
                            
                            if hasGetter
                            {
                                continue
                            }
                    }
                }
                
                
                
                guard let pattern
                        = binding.pattern.as(IdentifierPatternSyntax.self)
                else
                {
                    continue
                }
                
                let name: String = pattern.identifier.text
                
                
                
                guard let typeAnnotation: TypeAnnotationSyntax
                        = binding.typeAnnotation
                else
                {
                    missingAnnotations.append(name)
                    continue
                }
                
                let isImmutable: Bool = varDecl.bindingSpecifier.tokenKind
                    == .keyword(.let)
                
                let storedProperty = StoredProperty(
                    name:           name,
                    typeName:       typeAnnotation.type.trimmedDescription,
                    typeSyntax:     TypeSyntax(typeAnnotation.type),
                    isImmutable:    isImmutable,
                    hasDefault:     binding.initializer !=  nil
                )
                
                properties.append(storedProperty)
            }
        }
        
        
        
        return StoredProperties(
            properties:             properties,
            missingAnnotations:     missingAnnotations
        )
    }
}
