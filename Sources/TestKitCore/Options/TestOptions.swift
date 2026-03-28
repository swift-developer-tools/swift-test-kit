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
    /// The options for computing diffs.
    ///
    /// The default value is a default-initialized ``DiffOptions`` instance.
    public var diffOptions          : DiffOptions
    
    /// The options for formatting diffs.
    ///
    /// The default value is a default-initialized ``FormatOptions`` instance.
    public var formatOptions        : FormatOptions
    
    /// The options for property-based testing and stateful testing.
    ///
    /// The default value is a default-initialized ``PropertyOptions``
    /// instance.
    public var propertyOptions      : PropertyOptions
    
    /// The options for temporal testing.
    ///
    /// The default value is a default-initialized ``TemporalOptions``
    /// instance.
    public var temporalOptions      : TemporalOptions
    
    /// The options for performance testing.
    ///
    /// The default value is a default-initialized ``PerformanceOptions``
    /// instance.
    public var performanceOptions   : PerformanceOptions
    
    
    
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its properties.
    public init(
        diffOptions         : DiffOptions           = .init(),
        formatOptions       : FormatOptions         = .init(),
        propertyOptions     : PropertyOptions       = .init(),
        temporalOptions     : TemporalOptions       = .init(),
        performanceOptions  : PerformanceOptions    = .init()
    )
    {
        self.diffOptions            = diffOptions
        self.formatOptions          = formatOptions
        self.propertyOptions        = propertyOptions
        self.temporalOptions        = temporalOptions
        self.performanceOptions     = performanceOptions
    }
    
    
    
    /// Calls the given closure with a mutable copy of the receiver.
    /// - Parameter modify: The closure to modify the options for testing.
    /// - Returns: The modified options for testing.
    public func with(
        _ modify: (inout TestOptions) -> Void
    ) -> TestOptions
    {
        var copy: TestOptions = self
        
        modify(&copy)
        
        return copy
    }
}
