//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// TODO: Documentation.
@attached(
    extension,
    conformances:   Arbitrary,
    names:          named(arbitrary), named(shrink)
)
public macro Arbitrary() = #externalMacro(
    module:     "TestKitMacros",
    type:       "ArbitraryMacro"
)
