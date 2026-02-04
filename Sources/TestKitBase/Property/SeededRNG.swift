//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A deterministic random number generator.
internal struct SeededRNG: RandomNumberGenerator
{
    /// The seed used to initialize the random number generator.
    public let seed     : UInt64
    
    /// The current state.
    private var state   : UInt64
    
    
    
    /// Initializes a ``SeededRNG`` instance from the given seed.
    public init(
        seed: UInt64
    )
    {
        self.seed   = seed
        self.state  = seed
    }
    
    
    
    /// Generates the next random value.
    ///
    /// This uses the SplitMix64 algorithm (Sebastiano Vigna, 2015).
    ///
    /// - Returns: The next random value.
    public mutating func next() -> UInt64
    {
        state += 0x9e3779b97f4a7c15
        
        var next: UInt64 = state
        
        next = (next ^ (next >> 30)) * 0xbf58476d1ce4e5b9
        next = (next ^ (next >> 27)) * 0x94d049bb133111eb
        
        return next ^ (next >> 31)
    }
}
