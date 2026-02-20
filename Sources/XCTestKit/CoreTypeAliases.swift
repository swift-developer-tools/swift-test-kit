//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



// MARK: - Options

/// The options for testing.
///
/// - Note: See
/// [`TestOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/testoptions)
/// for the complete API reference.
public typealias TestOptions        = TestKitCore.TestOptions

/// The options for computing diffs.
///
/// - Note: See
/// [`DiffOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/diffoptions)
/// for the complete API reference.
public typealias DiffOptions        = TestKitCore.DiffOptions

/// The options for formatting assertion failures.
///
/// - Note: See
/// [`FormatOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/formatoptions)
/// for the complete API reference.
public typealias FormatOptions      = TestKitCore.FormatOptions

/// The options for property-based testing.
///
/// - Note: See
/// [`PropertyOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/propertyoptions)
/// for the complete API reference.
public typealias PropertyOptions    = TestKitCore.PropertyOptions



// MARK: - Assertions

/// The error thrown when unwrapping a value that is `nil`.
///
/// - Note: See
/// [`UnwrapError`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/unwraperror)
/// for the complete API reference.
public typealias UnwrapError        = TestKitCore.UnwrapError



// MARK: - Property-based testing

/// A type that can generate arbitrary random values.
///
/// - Note: See
/// [`Arbitrary`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/arbitrary)
/// for the complete API reference.
public typealias Arbitrary          = TestKitCore.Arbitrary

/// A custom generator for producing values of a specific type.
///
/// - Note: See
/// [`Generator`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/generator)
/// for the complete API reference.
public typealias Generator          = TestKitCore.Generator

/// The options for property-based testing.
///
/// - Note: See
/// [`GenerationContext`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/generationcontext)
/// for the complete API reference.
public typealias GenerationContext  = TestKitCore.GenerationContext
