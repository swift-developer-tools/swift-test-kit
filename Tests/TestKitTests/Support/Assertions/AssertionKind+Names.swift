//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



extension AssertionKind
{
    /// The assertion name.
    internal var name: String
    {
        return name(for: .xctk)
    }
    
    
    
    /// The internal macro name.
    internal var macroInternalName: String
    {
        return "_\(name)Macro"
    }
    
    
    
    /// The macro display name.
    internal var macroDisplayName: String
    {
        return "#\(name)"
    }
}
