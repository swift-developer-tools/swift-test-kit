//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal extension BinaryFloatingPoint
{
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
    
    
    
    /// Special values to occasionally generate.
    static var specialValues: [Self]
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
        if context.random(in: 1...20) == 1
        {
            return context.randomElement(of: specialValues) ?? 0.0
        }
        
        return nil
    }
}
