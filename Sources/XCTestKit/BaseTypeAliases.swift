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
/// [`TKOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/tkoptions)
/// for the complete API reference.
public typealias TKOptions          = TestKitCore.TKOptions

/// The options for computing diffs.
///
/// - Note: See
/// [`TKDiffOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/tkdiffoptions)
/// for the complete API reference.
public typealias TKDiffOptions      = TestKitCore.TKDiffOptions

/// The options for formatting assertion failures.
///
/// - Note: See
/// [`TKFormatOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/tkformatoptions)
/// for the complete API reference.
public typealias TKFormatOptions    = TestKitCore.TKFormatOptions

/// The options for property-based testing.
///
/// - Note: See
/// [`TKPropertyOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/tkpropertyoptions)
/// for the complete API reference.
public typealias TKPropertyOptions  = TestKitCore.TKPropertyOptions



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
