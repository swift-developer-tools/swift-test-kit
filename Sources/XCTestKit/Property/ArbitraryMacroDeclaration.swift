//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Synthesizes ``Arbitrary`` conformance for structs and enums.
///
/// Apply the `@Arbitrary` macro to a struct or enum to automatically
/// synthesize ``Arbitrary`` conformance.
///
/// ```swift
/// @Arbitrary
/// struct User: Equatable
/// {
///     let name    : String
///     let id      : Int
/// }
///
/// @Arbitrary
/// enum Shape: Equatable
/// {
///     case circle(radius: Int)
///     case rect(width: Int, height: Int)
///     case point
/// }
/// ```
///
/// ## Structs
///
/// All stored properties with explicit type annotations participate in
/// generation and shrinking. Computed, `static`, `lazy`, and `class`
/// properties are skipped. Properties without explicit type annotations are
/// not supported.
///
/// Immutable properties with default values (for example, `let x: Int = 100`)
/// are preserved as-is. Values for these properties are not randomly
/// generated, and the properties do not participate in shrinking. Mutable
/// properties with default values (for example, `var x: Int = 100`)
/// participate in generation and shrinking normally.
///
/// ## Enums
///
/// Conforming enums must have at least one case, and the cases are selected
/// uniformly at random. Associated values participate in generation, and
/// shrinking proceeds one associated value at a time within the matched case,
/// preserving the case itself.
///
/// Recursive and `indirect` enums are supported. Generation terminates by
/// selecting only base cases (cases without associated values) at small sizes.
/// Shrinking uses structural candidates to collapse recursive structures
/// toward the base cases.
///
/// ```swift
/// @Arbitrary
/// indirect enum Tree: Equatable
/// {
///     case leaf
///     case node(Tree, Tree)
/// }
/// ```
///
/// ## Generic Types
///
/// Generic parameters that appear in stored properties or enum associated
/// values are automatically constrained to ``Arbitrary`` in the generated
/// extension. Generic parameters that are unused are not constrained.
///
/// ```swift
/// @Arbitrary
/// struct Pair<A, B>: Equatable where A : Equatable, B : Equatable
/// {
///     let a   : A
///     let b   : B
/// }
/// ```
@attached(
    extension,
    conformances:   Arbitrary,
    names:          named(arbitrary), named(shrink), named(mutate)
)
public macro Arbitrary() = #externalMacro(
    module:     "TestKitMacros",
    type:       "ArbitraryMacro"
)
