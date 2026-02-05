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
/// [`TKOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitbase/tkoptions)
/// for the complete API reference.
public typealias TKOptions          = TestKitBase.TKOptions

/// The options for computing diffs.
///
/// - Note: See
/// [`TKDiffOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitbase/tkdiffoptions)
/// for the complete API reference.
public typealias TKDiffOptions      = TestKitBase.TKDiffOptions

/// The options for formatting assertion failures.
///
/// - Note: See
/// [`TKFormatOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitbase/tkformatoptions)
/// for the complete API reference.
public typealias TKFormatOptions    = TestKitBase.TKFormatOptions

/// The options for property-based testing.
///
/// - Note: See
/// [`TKPropertyOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitbase/tkpropertyoptions)
/// for the complete API reference.
public typealias TKPropertyOptions  = TestKitBase.TKPropertyOptions



// MARK: - Property-based testing

/// A type that can generate arbitrary random values.
///
/// - Note: See
/// [`Arbitrary`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitbase/arbitrary)
/// for the complete API reference.
public typealias Arbitrary          = TestKitBase.Arbitrary

/// The options for property-based testing.
///
/// - Note: See
/// [`GenerationContext`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitbase/generationcontext)
/// for the complete API reference.
public typealias GenerationContext  = TestKitBase.GenerationContext
