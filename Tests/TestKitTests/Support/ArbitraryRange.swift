//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// An arbitrary range.
internal protocol ArbitraryRange
{
    /// The type of the range's bounds.
    associatedtype Bound: Comparable
    
    
    
    /// The range's lower bound.
    var lowerBound: Bound { get }
    
    /// The range's upper bound.
    var upperBound: Bound { get }
    
    
    
    /// Initializes an ``ArbitraryRange`` from the given values.
    init(
        lower   : Bound,
        upper   : Bound
    )
}



extension ClosedRange: ArbitraryRange
{
    /// Initializes an arbitrary `ClosedRange` from the given values.
    internal init(
        lower   : Bound,
        upper   : Bound
    )
    {
        self = lower...upper
    }
}



extension Range: ArbitraryRange
{
    /// Initializes an arbitrary `Range` from the given values.
    internal init(
        lower   : Bound,
        upper   : Bound
    )
    {
        self = lower..<upper
    }
}
