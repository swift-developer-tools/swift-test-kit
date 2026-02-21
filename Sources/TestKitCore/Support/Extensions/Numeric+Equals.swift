//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Numeric
{
    /// Checks whether the receiver is equal to the given value, within the
    /// given accuracy.
    ///
    /// - Note: NaN values are handled by the comparison operator, which
    /// returns `false` if either operand is NaN.
    ///
    /// - Parameters:
    ///   - other: The other value to compare.
    ///   - accuracy: The accuracy.
    /// - Returns: Whether the receiver is equal to the given value, within
    /// the given accuracy.
    internal func equals(
        _ other     : Self,
        accuracy    : Self
    ) -> Bool
    {
        guard self != other
        else
        {
            return true
        }
        
        let difference: Self = self.magnitude > other.magnitude
            ? self - other
            : other - self
        
        return difference.magnitude <= accuracy.magnitude
    }
}
