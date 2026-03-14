//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A type with a customized structural diff string representation.
///
/// Types that conform to this protocol can control how a value appears in
/// structural diffs.
///
/// - Note: This affects only the rendered description, not the structural
/// comparison itself. See ``CustomDiffRepresentable`` for more information.
///
/// Conformance to this protocol takes precedence over all built-in diffing.
public protocol CustomDiffStringConvertible
{
    /// The custom string representation of a value for structural diffing.
    var diffDescription: String { get }
}
