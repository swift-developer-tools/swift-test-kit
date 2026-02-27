//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The options for testing.
public struct TestOptions: Equatable, Sendable
{
    /// Whether to compute and display diffs on assertion failure.
    ///
    /// The default value is `true`.
    public var diffEnabled      : Bool
    
    /// The options for computing diffs.
    ///
    /// The default value is a default-initialized ``DiffOptions`` instance.
    public var diffOptions      : DiffOptions
    
    /// The options for formatting diffs.
    ///
    /// The default value is a default-initialized ``FormatOptions`` instance.
    public var formatOptions    : FormatOptions
    
    /// The options for property-based testing.
    ///
    /// The default value is a default-initialized ``PropertyOptions``
    /// instance.
    public var propertyOptions  : PropertyOptions
    
    /// The options for temporal testing.
    ///
    /// The default value is a default-initialized ``TemporalOptions``
    /// instance.
    public var temporalOptions  : TemporalOptions
    
    
    
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its properties.
    public init(
        diffEnabled     : Bool              = true,
        diffOptions     : DiffOptions       = .init(),
        formatOptions   : FormatOptions     = .init(),
        propertyOptions : PropertyOptions   = .init(),
        temporalOptions : TemporalOptions   = .init()
    )
    {
        self.diffEnabled        = diffEnabled
        self.diffOptions        = diffOptions
        self.formatOptions      = formatOptions
        self.propertyOptions    = propertyOptions
        self.temporalOptions    = temporalOptions
    }
}
