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
    /// The access level of the declaration, or `nil` for implicit internal.
    internal var accessLevel: String?
    {
        for modifier in modifiers
        {
            switch modifier.name.tokenKind
            {
                case
                    .keyword(.public),
                    .keyword(.package),
                    .keyword(.internal),
                    .keyword(.fileprivate),
                    .keyword(.private):
                    
                    return modifier.name.text
                    
                default:
                    
                    continue
            }
        }
        
        return nil
    }
}
