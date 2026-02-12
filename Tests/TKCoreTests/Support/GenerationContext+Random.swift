//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitCore



extension GenerationContext
{
    /// A generation context with a random seed and size.
    internal static var random: GenerationContext
    {
        return GenerationContext(
            seed:   randomSeed,
            size:   randomSize
        )
    }
    
    
    
    /// A random generation context with a random seed and zero size.
    internal static var randomZeroSize: GenerationContext
    {
        return GenerationContext(
            seed:   randomSeed,
            size:   0
        )
    }
    
    
    
    /// A tuple of generation contexts initialized using the same random
    /// seeds and sizes.
    internal static var sameRandomContexts:
        (GenerationContext, GenerationContext)
    {
        let seed    : UInt64    = GenerationContext.randomSeed
        let size    : Int       = GenerationContext.randomSize
        
        let context1    = GenerationContext(seed: seed, size: size)
        let context2    = GenerationContext(seed: seed, size: size)
        
        return (context1, context2)
    }
    
    
    
    /// A random seed.
    internal static var randomSeed: UInt64
    {
        return .random(in: UInt64.min...UInt64.max)
    }
    
    
    
    /// A random size.
    internal static var randomSize: Int
    {
        return .random(in: 0...100)
    }
}
