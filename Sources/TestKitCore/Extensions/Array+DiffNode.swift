//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

package extension Array<DiffNode>
{
    /// Whether the diff tree represents a set.
    var isSetTree: Bool
    {
        guard !self.isEmpty
        else
        {
            return false
        }
        
        for node in self
        {
            guard node.label.isMember
            else
            {
                return false
            }
        }
        
        return true
    }
}
