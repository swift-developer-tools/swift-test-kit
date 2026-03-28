//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



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
