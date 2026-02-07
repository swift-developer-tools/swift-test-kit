//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

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
        
        let integer     = Double(context.random(in: -bound...bound))
        let fraction    = Double(context.random(in: -1.0...1.0))
        
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
        
        let integer     = Float(context.random(in: -bound...bound))
        let fraction    = Float(context.random(in: -1.0...1.0))
        
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
        
        let integer     = Float16(context.random(in: -bound...bound))
        let fraction    = Float16(context.random(in: -1.0...1.0))
        
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
