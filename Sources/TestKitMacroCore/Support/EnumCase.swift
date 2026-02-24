//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



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
