//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore



extension Generator
{
    /// Initializes a ``Generator`` instance from the given values, using the
    /// given generation function as the mutation function.
    ///
    /// This initializer allows existing tests that do not test mutation to
    /// avoid providing a mutation method. Since mutation was added long after
    /// the initial ``Generator`` functionality, many tests would otherwise
    /// need to specify an irrelevant mutation method.
    ///
    /// - Parameters:
    ///   - generate: The function to generate a value from the given context.
    ///   - shrink: The function to shrink the given value.
    internal init(
        generate    : @escaping (GenerationContext) -> V,
        shrink      : @escaping (V) -> [V]
    )
    {
        self = Generator(
            generate:   generate,
            shrink:     shrink,
            mutate:     { _, context in generate(context) }
        )
    }
}
