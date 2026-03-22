//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension Generator where G == Date
{
    /// Creates a generator that produces dates within the given range.
    ///
    /// Shrink candidates converge toward the reference date (00:00:00 UTC on
    /// 1 January 2001) if the reference date is within the given range.
    /// Otherwise, shrink candidates converge toward the nearest bound.
    ///
    /// - Parameter range: The range of valid dates.
    /// - Returns: A generator that produces dates within the given range.
    public static func date(
        in range: ClosedRange<Date>
    ) -> Generator<Date>
    {
        let lower: TimeInterval
            = range.lowerBound.timeIntervalSinceReferenceDate
        
        let upper: TimeInterval
            = range.upperBound.timeIntervalSinceReferenceDate
        
        return Generator<Date>(
            generate:
            {
                context in
                
                let interval: TimeInterval = context.random(in: lower...upper)
                
                return Date(timeIntervalSinceReferenceDate: interval)
            },
            shrink:
            {
                date in
                
                let interval: TimeInterval
                    = date.timeIntervalSinceReferenceDate
                
                return interval.shrinkTowardZero(in: lower...upper)
                    .map { Date(timeIntervalSinceReferenceDate: $0) }
            },
            mutate:
            {
                date, context in
                
                return mutateDate(
                    date,
                    lowerBound:     lower,
                    upperBound:     upper,
                    using:          context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces dates within the given range.
    ///
    /// Shrink candidates converge toward the reference date (00:00:00 UTC on
    /// 1 January 2001) if the reference date is within the given range.
    /// Otherwise, shrink candidates converge toward the nearest bound.
    ///
    /// - Precondition: `range` must not be empty.
    ///
    /// - Parameter range: The range of valid dates.
    /// - Returns: A generator that produces dates within the given range.
    public static func date(
        in range: Range<Date>
    ) -> Generator<Date>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        let lower: TimeInterval
            = range.lowerBound.timeIntervalSinceReferenceDate
        
        let upper: TimeInterval
            = range.upperBound.timeIntervalSinceReferenceDate
        
        return Generator<Date>(
            generate:
            {
                context in
                
                let interval: TimeInterval = context.random(in: lower..<upper)
                
                return Date(timeIntervalSinceReferenceDate: interval)
            },
            shrink:
            {
                date in
                
                let interval: TimeInterval
                    = date.timeIntervalSinceReferenceDate
                
                return interval.shrinkTowardZero(in: lower...upper)
                    .filter { $0 < upper }
                    .map { Date(timeIntervalSinceReferenceDate: $0) }
            },
            mutate:
            {
                date, context in
                
                return mutateDate(
                    date,
                    lowerBound:     lower,
                    upperBound:     upper.nextDown,
                    using:          context
                )
            }
        )
    }
    
    
    
    // MARK: - Support
    
    /// Mutates the given date.
    /// - Parameters:
    ///   - date: The date to mutate.
    ///   - lowerBound: The lower bound of the time interval.
    ///   - upperBound: The upper bound of the time interval.
    ///   - context: The generation context.
    /// - Returns: The mutated date.
    private static func mutateDate(
        _ date          : Date,
        lowerBound      : TimeInterval,
        upperBound      : TimeInterval,
        using context   : GenerationContext
    ) -> Date
    {
        let maxDays = Double(max(1, context.size))
        
        let delta: TimeInterval
            = context.random(in: -maxDays...maxDays) * 60 * 60 * 24
        
        let interval: TimeInterval = min(
            upperBound,
            max(lowerBound, date.timeIntervalSinceReferenceDate + delta)
        )
        
        return Date(timeIntervalSinceReferenceDate: interval)
    }
}
