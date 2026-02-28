//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore



extension SeededRNG
{
    /// A random number generator with a random seed.
    internal static var random: SeededRNG
    {
        return SeededRNG(seed: GenerationContext.randomSeed)
    }
}
