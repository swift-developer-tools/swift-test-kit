//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Collection
{
    /// Whether the collection is ordered.
    package var isOrdered: Bool
    {
        let mirror = Mirror(reflecting: self)
        
        return mirror.displayStyle != .dictionary
            && mirror.displayStyle != .set
    }
}
