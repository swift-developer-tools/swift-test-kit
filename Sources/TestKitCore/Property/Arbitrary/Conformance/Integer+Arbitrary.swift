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
    /// `-context.size...context.size`. Occasionally generates special values
    /// (`0`, `±1`, `.min`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int
    {
        if let special: Int = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> Int
    {
        return mutateValue(using: context)
    }
}



// MARK: - Int8

extension Int8: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `-bound...bound`, where
    /// `bound` is the lesser of `context.size` and `Int8.max`.  Occasionally
    /// generates special values (`0`, `±1`, `.min`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int8
    {
        if let special: Int8 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> Int8
    {
        return mutateValue(using: context)
    }
}



// MARK: - Int16

extension Int16: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `-bound...bound`, where
    /// `bound` is the lesser of `context.size` and `Int16.max`. Occasionally
    /// generates special values (`0`, `±1`, `.min`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int16
    {
        if let special: Int16 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> Int16
    {
        return mutateValue(using: context)
    }
}



// MARK: - Int32

extension Int32: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `-bound...bound`, where
    /// `bound` is the lesser of `context.size` and `Int32.max`. Occasionally
    /// generates special values (`0`, `±1`, `.min`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int32
    {
        if let special: Int32 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> Int32
    {
        return mutateValue(using: context)
    }
}



// MARK: - Int64

extension Int64: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range
    /// `-context.size...context.size`. Occasionally generates special values
    /// (`0`, `±1`, `.min`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Int64
    {
        if let special: Int64 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> Int64
    {
        return mutateValue(using: context)
    }
}



// MARK: - UInt

extension UInt: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...context.size`.
    /// Occasionally generates special values (`0`, `1`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt
    {
        if let special: UInt = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> UInt
    {
        return mutateValue(using: context)
    }
}



// MARK: - UInt8

extension UInt8: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...bound`, where
    /// `bound` is the lesser of `context.size` and `UInt8.max`. Occasionally
    /// generates special values (`0`, `1`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt8
    {
        if let special: UInt8 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> UInt8
    {
        return mutateValue(using: context)
    }
}



// MARK: - UInt16

extension UInt16: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...bound`, where
    /// `bound` is the lesser of `context.size` and `UInt16.max`. Occasionally
    /// generates special values (`0`, `1`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt16
    {
        if let special: UInt16 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> UInt16
    {
        return mutateValue(using: context)
    }
}



// MARK: - UInt32

extension UInt32: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range `0...bound`, where
    /// `bound` is the lesser of `context.size` and `UInt32.max`. Occasionally
    /// generates special values (`0`, `1`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt32
    {
        if let special: UInt32 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> UInt32
    {
        return mutateValue(using: context)
    }
}



// MARK: - UInt64

extension UInt64: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary integer in the range
    /// `-context.size...context.size`. Occasionally generates special values
    /// (`0`, `1`, `.max`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> UInt64
    {
        if let special: UInt64 = specialValue(using: context)
        {
            return special
        }
        
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
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    public func mutate(
        using context: GenerationContext
    ) -> UInt64
    {
        return mutateValue(using: context)
    }
}



// MARK: - Support

extension FixedWidthInteger
{
    /// Shrinks the value toward zero or the nearest bound by repeatedly
    /// halving the distance.
    ///
    /// Shrink candidates converge toward zero if zero is within the range,
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
    
    
    
    /// Special values to occasionally generate.
    internal static var specialValues: [Self]
    {
        if isSigned
        {
            return [0, 1, -1, .min, .max]
        }
        
        return [0, 1, .max]
    }
    
    
    
    /// Generates a special value 5% of the time.
    /// - Parameter context: The generation context.
    /// - Returns: A special value or `nil`.
    internal static func specialValue(
        using context: GenerationContext
    ) -> Self?
    {
        if context.random(in: 1...20) == 1
        {
            return context.randomElement(of: specialValues) ?? 0
        }
        
        return nil
    }
    
    
    
    /// Mutates the value by adding a random amount scaled by
    /// ``GenerationContext/size``.
    ///
    /// If the random amount is zero, the receiver value is returned.
    /// Overflows are clamped to the representable range.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: A mutated integer.
    internal func mutateValue(
        using context: GenerationContext
    ) -> Self
    {
        let maxDelta    : Int   = Swift.max(1, context.size)
        let delta       : Int   = context.random(in: -maxDelta...maxDelta)
        
        if delta == 0
        {
            return self
        }
        else if delta > 0
        {
            let amount = Self(clamping: delta)
            
            let (result, overflow): (Self, Bool)
                = self.addingReportingOverflow(amount)
            
            return overflow
                ? .max
                : result
        }
        else
        {
            let amount = Self(clamping: -delta)
            
            let (result, overflow): (Self, Bool)
                = self.subtractingReportingOverflow(amount)
            
            return overflow
                ? .min
                : result
        }
    }
}
