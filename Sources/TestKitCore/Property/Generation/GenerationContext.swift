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
    private var rng     : SeededRNG
    
    /// The current generation depth.
    private var depth   : Int       = 0
    
    /// The maximum generation depth.
    ///
    /// A precondition failure is triggered if ``withReducedSize(by:_:)``
    /// exceeds this depth. This guards against infinite recursion between
    /// mutually recursive types that lack reachable base cases.
    private static let maxDepth: Int = 500
    
    
    
    /// Initializes a ``GenerationContext`` instance from the given values.
    ///
    /// This is used by property runners.
    ///
    /// - Precondition: `size` must be non-negative.
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
}



// MARK: - Size

extension GenerationContext
{
    /// Calls the given closure with a reduced generation size.
    ///
    /// The generation size is divided by the given divisor, then restored
    /// after the closure returns.
    ///
    /// Use this to ensure termination when generating values for recursive
    /// ``Arbitrary`` types.
    ///
    /// - Precondition: `divisor` must be greater than `1`.
    /// - Precondition: The generation depth must not exceed the maximum
    /// depth. Exceeding the maximum depth usually indicates mutual recursion
    /// between types without a reachable base case.
    ///
    /// - Parameters:
    ///   - divisor: The divisor by which to reduce the generation size.
    ///   The default value is `2`.
    ///   - body: The closure to call.
    /// - Returns: The value returned by the given closure.
    public func withReducedSize<T>(
        by  divisor : Int       = 2,
        _   body    : () -> T
    ) -> T
    {
        precondition(
            divisor > 1,
            "divisor must be greater than 1"
        )
        
        depth += 1
        
        precondition(
            depth <= Self.maxDepth,
            "GenerationContext exceeded maximum generation depth"
            + " (\(Self.maxDepth)). This usually indicates mutual recursion"
            + " between types without a reachable base case."
        )
        
        let saved: Int = size
        
        size = size / divisor
        
        defer
        {
            size    = saved
            depth   -= 1
        }
        
        return body()
    }
}



// MARK: - Random

extension GenerationContext
{
    /// Creates a random integer in the given range.
    /// - Parameter range: The range in which to create a random integer.
    /// - Returns: A random integer in the given range.
    public func random<T>(
        in range: ClosedRange<T>
    ) -> T where T : FixedWidthInteger
    {
        return T.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random integer in the given range.
    /// - Parameter range: The range in which to create a random integer.
    /// - Returns: A random integer in the given range.
    public func random<T>(
        in range: Range<T>
    ) -> T where T : FixedWidthInteger
    {
        return T.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random double in the given range.
    /// - Parameter range: The range in which to create a random double.
    /// - Returns: A random double in the given range.
    public func random<T>(
        in range: Range<T>
    ) -> T where T : BinaryFloatingPoint, T.RawSignificand : FixedWidthInteger
    {
        return T.random(
            in:     range,
            using:  &rng
        )
    }
    
    
    
    /// Creates a random double in the given range.
    /// - Parameter range: The range in which to create a random double.
    /// - Returns: A random double in the given range.
    public func random<T>(
        in range: ClosedRange<T>
    ) -> T where T : BinaryFloatingPoint, T.RawSignificand : FixedWidthInteger
    {
        return T.random(
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
    
    
    
    /// Gets a random element of the given collection, weighted by the given
    /// closure.
    ///
    /// - Precondition: All weights must be positive.
    ///
    /// - Parameters:
    ///   - collection: The collection from which to retrieve a random element.
    ///   - weight: A closure that returns the weight for a given element.
    /// - Returns: A random element of the given collection, or `nil` if the
    /// collection is empty.
    public func randomElement<C>(
        of          collection  : C,
        weightedBy  weight      : (C.Element) -> Int
    ) -> C.Element? where C : Collection
    {
        guard !collection.isEmpty
        else
        {
            return nil
        }
        
        let total: Int = collection.reduce(0)
        {
            let w: Int = weight($1)
            
            precondition(
                w > 0,
                "All weights must be positive"
            )
            
            return $0 + w
        }
        
        var remaining: Int = random(in: 1...total)
        
        for element in collection
        {
            remaining -= weight(element)
            
            if remaining <= 0
            {
                return element
            }
        }
        
        /// This should be unreachable given valid weights.
        return nil
    }
}
