//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// TODO: Documentation
/// Synthesizes ``Stateful`` conformance for structs and enums.
@attached(
    extension,
    conformances:   Stateful,
    names:          named(arbitrary), named(shrink)
)
public macro Stateful() = #externalMacro(
    module:     "TestKitMacros",
    type:       "StatefulMacro"
)
