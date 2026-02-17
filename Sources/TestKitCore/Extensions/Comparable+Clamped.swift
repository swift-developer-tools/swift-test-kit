//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

package extension Comparable
{
    /// Clamps the value to the given range.
    /// - Parameter range: The range to use.
    /// - Returns: The clamped value.
    func clamped(
        to range: ClosedRange<Self>
    ) -> Self
    {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
