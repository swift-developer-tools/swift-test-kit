//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Extensions

private extension BinaryFloatingPoint
{
    /// Returns the maximum magnitude for generation, based on the type's
    /// representable range.
    ///
    /// If `greatestFiniteMagnitude` is less than `Int.max`, this returns the
    /// lesser of ``GenerationContext/size`` and the greatest finite magnitude.
    /// Otherwise, it returns ``GenerationContext/size``.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: The generation bound.
    static func bound(
        from context: GenerationContext
    ) -> Int
    {
        if Self.greatestFiniteMagnitude < Self(Int.max)
        {
            return Swift.min(context.size, Int(Self.greatestFiniteMagnitude))
        }
        
        return context.size
    }
    
    
    
    /// Shrinks the value toward zero.
    /// - Returns: The shrink candidates.
    func shrinkTowardZero() -> [Self]
    {
        guard
            self.isFinite,
            !self.isNaN
        else
        {
            return [0.0]
        }
        
        guard self != 0.0
        else
        {
            return []
        }
        
        
        
        var candidates: [Self] = [0.0]
        
        /// Truncate the fractional part.
        let truncated: Self = self.rounded(.towardZero)
        
        if
            truncated != self,
            truncated != 0.0
        {
            candidates.append(truncated)
        }
        
        
        
        /// Halve toward zero.
        var current: Self = truncated != 0.0
            ? truncated
            : self
        
        while abs(current) > 0.5
        {
            current /= 2.0
            current.round(.towardZero)
            
            if current != 0.0
            {
                candidates.append(current)
            }
        }
        
        return candidates
    }
    
    
    
    /// Special values to occasionally generate.
    private static var specialValues: [Self]
    {
        return [
            -0.0,
            .infinity,
            -.infinity,
            .nan
        ]
    }
    
    
    
    /// Generates a special value 5% of the time.
    /// - Parameter context: The generation context.
    /// - Returns: A special value or `nil`.
    static func specialValue(
        using context: GenerationContext
    ) -> Self?
    {
        if context.randomInt(in: 1...20) == 1
        {
            return context.randomElement(of: specialValues) ?? 0.0
        }
        
        return nil
    }
}



// MARK: - Double

extension Double: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary value in the range
    /// `-context.size...context.size`, with a fractional component.
    /// Occasionally generates special values (`0`, `-0`, `±infinity`, `nan`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Double
    {
        if let specialValue = Double.specialValue(using: context)
        {
            return specialValue
        }
        
        let bound: Int = Double.bound(from: context)
        
        let integer     = Double(context.randomInt(in: -bound...bound))
        let fraction    = Double(context.randomDouble(in: -1.0...1.0))
        
        return integer + fraction
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Special values shrink to `0`. Finite values shrink toward `0` by
    /// truncating the fractional part, then repeatedly halving.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Double]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Float

extension Float: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary value in the range
    /// `-context.size...context.size`, with a fractional component.
    /// Occasionally generates special values (`0`, `-0`, `±infinity`, `nan`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Float
    {
        if let specialValue = Float.specialValue(using: context)
        {
            return specialValue
        }
        
        let bound: Int = Float.bound(from: context)
        
        let integer     = Float(context.randomInt(in: -bound...bound))
        let fraction    = Float(context.randomDouble(in: -1.0...1.0))
        
        return integer + fraction
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Special values shrink to `0`. Finite values shrink toward `0` by
    /// truncating the fractional part, then repeatedly halving.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Float]
    {
        return self.shrinkTowardZero()
    }
}



// MARK: - Float16

extension Float16: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary value in the range
    /// `-context.size...context.size`, with a fractional component.
    /// Occasionally generates special values (`0`, `-0`, `±infinity`, `nan`).
    public static func arbitrary(
        using context: GenerationContext
    ) -> Float16
    {
        if let specialValue = Float16.specialValue(using: context)
        {
            return specialValue
        }
        
        let bound: Int = Float16.bound(from: context)
        
        let integer     = Float16(context.randomInt(in: -bound...bound))
        let fraction    = Float16(context.randomDouble(in: -1.0...1.0))
        
        return integer + fraction
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Special values shrink to `0`. Finite values shrink toward `0` by
    /// truncating the fractional part, then repeatedly halving.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Float16]
    {
        return self.shrinkTowardZero()
    }
}
