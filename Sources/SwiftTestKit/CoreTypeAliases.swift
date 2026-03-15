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

/// The global configuration.
///
/// - Note: See
/// [`TestConfiguration`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/testconfiguration)
/// for the complete API reference.
public typealias TestConfiguration      = TestKitCore.TestConfiguration

/// The options for testing.
///
/// - Note: See
/// [`TestOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/testoptions)
/// for the complete API reference.
public typealias TestOptions            = TestKitCore.TestOptions

/// The options for computing diffs.
///
/// - Note: See
/// [`DiffOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/diffoptions)
/// for the complete API reference.
public typealias DiffOptions            = TestKitCore.DiffOptions

/// The options for formatting assertion failures.
///
/// - Note: See
/// [`FormatOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/formatoptions)
/// for the complete API reference.
public typealias FormatOptions          = TestKitCore.FormatOptions

/// The options for property-based testing.
///
/// - Note: See
/// [`PropertyOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/propertyoptions)
/// for the complete API reference.
public typealias PropertyOptions        = TestKitCore.PropertyOptions

/// The options for temporal testing.
///
/// - Note: See
/// [`TemporalOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/temporaloptions)
/// for the complete API reference.
public typealias TemporalOptions        = TestKitCore.TemporalOptions

/// The options for performance testing.
///
/// - Note: See
/// [`PerformanceOptions`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/performanceoptions)
/// for the complete API reference.
public typealias PerformanceOptions     = TestKitCore.PerformanceOptions



// MARK: - Diff

/// A type with a customized structural diff representation.
///
/// - Note: See
/// [`CustomDiffRepresentable`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/customdiffrepresentable)
/// for the complete API reference.
public typealias CustomDiffRepresentable  = TestKitCore.CustomDiffRepresentable

/// A type with a customized structural diff representation.
///
/// - Note: See
/// [`DiffRepresentation`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/diffrepresentation)
/// for the complete API reference.
public typealias DiffRepresentation       = TestKitCore.DiffRepresentation

/// A custom representation of a value for structural diffing.
///
/// - Note: See
/// [`CustomDiffStringConvertible`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/customdiffstringconvertible)
/// for the complete API reference.
public typealias CustomDiffStringConvertible
    = TestKitCore.CustomDiffStringConvertible



// MARK: - Assertions

/// The error thrown when unwrapping a value that is `nil`.
///
/// - Note: See
/// [`UnwrapError`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/unwraperror)
/// for the complete API reference.
public typealias UnwrapError = TestKitCore.UnwrapError



// MARK: - Performance testing

/// A representation of memory, in bytes.
///
/// - Note: See
/// [`ByteCount`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/bytecount)
/// for the complete API reference.
public typealias ByteCount = TestKitCore.ByteCount



// MARK: - Property-based testing

/// A type that can generate arbitrary random values.
///
/// - Note: See
/// [`Arbitrary`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/arbitrary)
/// for the complete API reference.
public typealias Arbitrary              = TestKitCore.Arbitrary

/// A custom generator for producing values of a specific type.
///
/// - Note: See
/// [`Generator`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/generator)
/// for the complete API reference.
public typealias Generator              = TestKitCore.Generator

/// The options for property-based testing.
///
/// - Note: See
/// [`GenerationContext`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/generationcontext)
/// for the complete API reference.
public typealias GenerationContext      = TestKitCore.GenerationContext

/// A type that defines commands for stateful property-based testing.
///
/// - Note: See
/// [`Stateful`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/stateful)
/// for the complete API reference.
public typealias Stateful               = TestKitCore.Stateful

/// The options for reporting command statistics in stateful property-based
/// tests.
///
/// - Note: See
/// [`CommandStatistics`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/commandstatistics)
/// for the complete API reference.
public typealias CommandStatistics      = TestKitCore.CommandStatistics

/// The options for reporting diagnostics in property-based tests.
///
/// - Note: See
/// [`PropertyDiagnostics`](https://swift-developer-tools.github.io/swift-test-kit/documentation/testkitcore/propertydiagnostics)
/// for the complete API reference.
public typealias PropertyDiagnostics    = TestKitCore.PropertyDiagnostics
