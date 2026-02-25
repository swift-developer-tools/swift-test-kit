//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// TODO: Documentation
@attached(peer)
public macro Weight(
    _ weight: Int
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "WeightMacro"
)
