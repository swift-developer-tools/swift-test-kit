//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension Date: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    ///
    /// The generated date is offset from the reference date (00:00:00 UTC on
    /// 1 January 2001) by a number of days scaled by
    /// ``GenerationContext/size``. At the default maximum size of `100`, this
    /// produces dates within approximately ±100 days of the reference date.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary date within `±context.size` days of the
    /// reference date, with sub-second precision.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Date
    {
        let days = Double(context.random(in: -context.size...context.size))
        
        let fraction    : Double        = context.random(in: -1.0...1.0)
        let interval    : TimeInterval  = (days + fraction) * 60 * 60 * 24
        
        return Date(timeIntervalSinceReferenceDate: interval)
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward the reference date (00:00:00 UTC on
    /// 1 January 2001) by shrinking the underlying time interval.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Date]
    {
        let interval: TimeInterval = timeIntervalSinceReferenceDate
        
        return interval.shrinkTowardZero().map
        {
            return Date(timeIntervalSinceReferenceDate: $0)
        }
    }
}
