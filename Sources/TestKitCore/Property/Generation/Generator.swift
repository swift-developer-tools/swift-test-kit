//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A custom generator for producing values of a specific type.
public struct Generator<G>
{
    /// Generates a value from the given context.
    internal let generate   : (GenerationContext) -> G
    
    /// Shrinks the given value.
    internal let shrink     : (G) -> [G]
    
    /// Mutates the given value, using the given context.
    internal let mutate     : (G, GenerationContext) -> G
    
    
    
    /// Initializes a ``Generator`` instance from the given values.
    /// - Parameters:
    ///   - generate: The function to generate a value from the given context.
    ///   - shrink: The function to shrink the given value.
    ///   - mutate: The function to mutate the given value, using the given
    ///   context.
    public init(
        generate    : @escaping (GenerationContext) -> G,
        shrink      : @escaping (G) -> [G],
        mutate      : @escaping (G, GenerationContext) -> G
    )
    {
        self.generate   = generate
        self.shrink     = shrink
        self.mutate     = mutate
    }
}
