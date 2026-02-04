//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The context for generating arbitrary values.
public final class GenerationContext
{
    /// The current generation size.
    ///
    /// This controls the magnitude of generated values. The size begins at
    /// `0` and grows linearly across iterations, meaning earlier iterations
    /// test small values (for example, zero, empty arrays, and short strings),
    /// while later iterations test larg values.
    public package(set) var size: Int
    {
        didSet
        {
            precondition(
                size >= 0,
                "size must be non-negative"
            )
        }
    }
    
    /// The seeded random number generator.
    private var rng: SeededRNG
    
    
    
    /// Initializes a ``GenerationContext`` instance from the given values.
    ///
    /// This is used by property runners.
    internal init(
        seed    : UInt64,
        size    : Int       = 0
    )
    {
        precondition(
            size >= 0,
            "size must be non-negative"
        )
        
        self.rng    = SeededRNG(seed: seed)
        self.size   = size
    }
    
    
    
    /// Initializes a ``GenerationContext`` instance from the given seed.
    public convenience init(
        seed: UInt64
    )
    {
        self.init(
            seed:   seed,
            size:   0
        )
    }
    
    
    
    /// The seed used to initialize the RNG.
    public var seed: UInt64
    {
        return rng.seed
    }
    
    
    
    /// Creates a random integer in the given range.
    /// - Parameter range: The range in which to create a random integer.
    /// - Returns: A random integer in the given range.
    public func randomInt(
        in range: ClosedRange<Int>
    ) -> Int
    {
        return Int.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random integer in the given range.
    /// - Parameter range: The range in which to create a random integer.
    /// - Returns: A random integer in the given range.
    public func randomInt(
        in range: Range<Int>
    ) -> Int
    {
        return Int.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random double in the given range.
    /// - Parameter range: The range in which to create a random double.
    /// - Returns: A random double in the given range.
    public func randomDouble(
        in range: Range<Double>
    ) -> Double
    {
        return Double.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random double in the given range.
    /// - Parameter range: The range in which to create a random double.
    /// - Returns: A random double in the given range.
    public func randomDouble(
        in range: ClosedRange<Double>
    ) -> Double
    {
        return Double.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random Boolean.
    /// - Returns: A random Boolean.
    public func randomBool() -> Bool
    {
        return Bool.random(using: &rng)
    }
    
    
    
    /// Gets a random element of the given collection.
    /// - Parameter collection: The collection from which to retrieve a
    /// random element.
    /// - Returns: A random element of the given collection, or `nil` if the
    /// collection is empty.
    public func randomElement<C>(
        of collection: C
    ) -> C.Element? where C : Collection
    {
        return collection.randomElement(using: &rng)
    }
}
