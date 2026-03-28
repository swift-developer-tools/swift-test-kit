//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator where G : Arbitrary
{
    /// Creates a generator that produces values by delegating to the type's
    /// ``Arbitrary`` conformance.
    /// - Returns: A generator that produces values by delegating to the type's
    /// ``Arbitrary`` conformance.
    public static func arbitrary() -> Generator<G>
    {
        return Generator<G>(
            generate:   { context in G.arbitrary(using: context) },
            shrink:     { value in value.shrink() },
            mutate:     { value, context in value.mutate(using: context) }
        )
    }
}
