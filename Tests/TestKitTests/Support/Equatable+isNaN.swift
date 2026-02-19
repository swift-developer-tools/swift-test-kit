//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Equatable
{
    /// Whether the value is NaN (not a number).
    internal var isNaN: Bool
    {
        if let float = self as? any BinaryFloatingPoint
        {
            return float.isNaN
        }
        
        return false
    }
}
