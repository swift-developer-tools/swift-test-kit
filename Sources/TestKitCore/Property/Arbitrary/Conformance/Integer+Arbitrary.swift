//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Int

extension Int: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range
    /// `-context.size...context.size`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int
    {
        return context.random(in: -context.size...context.size)
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Int]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Int8

extension Int8: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `-bound...bound`, where
    /// `bound` is the lesser of `context.size` and `Int8.max`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int8
    {
        let bound: Int = Swift.min(context.size, Int(Int8.max))
        
        return Int8(context.random(in: -bound...bound))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Int8]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Int16

extension Int16: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `-bound...bound`, where
    /// `bound` is the lesser of `context.size` and `Int16.max`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int16
    {
        let bound: Int = Swift.min(context.size, Int(Int16.max))
        
        return Int16(context.random(in: -bound...bound))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Int16]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Int32

extension Int32: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `-bound...bound`, where
    /// `bound` is the lesser of `context.size` and `Int32.max`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int32
    {
        let bound: Int = Swift.min(context.size, Int(Int32.max))
        
        return Int32(context.random(in: -bound...bound))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Int32]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Int64

extension Int64: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range
    /// `-context.size...context.size`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int64
    {
        return Int64(context.random(in: -context.size...context.size))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Int64]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - UInt

extension UInt: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...context.size`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt
    {
        return UInt(context.random(in: 0...context.size))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [UInt]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - UInt8

extension UInt8: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...bound`, where
    /// `bound` is the lesser of `context.size` and `UInt8.max`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt8
    {
        let bound: Int = Swift.min(context.size, Int(UInt8.max))
        
        return UInt8(context.random(in: 0...bound))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [UInt8]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - UInt16

extension UInt16: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...bound`, where
    /// `bound` is the lesser of `context.size` and `UInt16.max`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt16
    {
        let bound: Int = Swift.min(context.size, Int(UInt16.max))
        
        return UInt16(context.random(in: 0...bound))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [UInt16]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - UInt32

extension UInt32: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...bound`, where
    /// `bound` is the lesser of `context.size` and `UInt32.max`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt32
    {
        let bound: Int = Swift.min(context.size, Int(UInt32.max))
        
        return UInt32(context.random(in: 0...bound))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [UInt32]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - UInt64

extension UInt64: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range
    /// `-context.size...context.size`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt64
    {
        return UInt64(context.random(in: 0...context.size))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates converge toward zero by repeatedly halving the distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [UInt64]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Support

extension FixedWidthInteger
{
    /// Shrinks the value toward zero or the nearest bound by repeatedly
    /// halving the distance.
    ///
    /// Shrink candidates converage toward zero if zero is within the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: The shrink candidates.
    internal func shrinkTowardZero(
        in range: ClosedRange<Self>? = nil
    ) -> [Self]
    {
        guard
            let range,
            !range.isEmpty
        else
        {
            return Self.shrink(self, toward: 0)
        }
        
        let target: Self
        
        if range.contains(0)
        {
            target = 0
        }
        else if 0 < range.lowerBound
        {
            target = range.lowerBound
        }
        else
        {
            target = range.upperBound
        }
        
        return Self.shrink(self, toward: target)
            .filter { range.contains($0) }
    }
    
    
    
    /// Shrinks the given value toward the given target by repeatedly halving
    /// the distance.
    /// - Parameters:
    ///   - value: The value to shrink.
    ///   - target: The value toward which shrink candidates converge.
    /// - Returns: The shrink candidates.
    private static func shrink(
        _       value   : Self,
        toward  target  : Self
    ) -> [Self]
    {
        guard value != target
        else
        {
            return []
        }
        
        var candidates  : [Self]    = [target]
        var distance    : Self      = value - target
        
        while true
        {
            distance /= 2
            
            if distance == 0
            {
                break
            }
            
            candidates.append(value - distance)
        }
        
        return candidates
    }
}
