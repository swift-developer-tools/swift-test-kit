//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The options for temporal testing.
public struct TemporalOptions: Equatable, Sendable
{
    /// The timeout duration.
    ///
    /// The default value is 2 seconds.
    public var timeout  : Duration
    
    /// The polling interval.
    ///
    /// The default value is 50 milliseconds.
    public var interval : Duration
    
    
    
    /// Initializes a ``TemporalOptions`` instance, optionally specifying
    /// values for its properties.
    ///
    /// - Precondition: `timeout` and `interval` must both be positive.
    /// - Precondition: `timeout` must be greater than or equal to `interval`
    public init(
        timeout     : Duration  = .seconds(2),
        interval    : Duration  = .milliseconds(50)
    )
    {
        precondition(
            timeout > .zero,
            "timeout must be positive"
        )
        
        precondition(
            interval > .zero,
            "interval must be positive"
        )
        
        precondition(
            timeout >= interval,
            "timeout must be greater than or equal to interval"
        )
        
        self.timeout    = timeout
        self.interval   = interval
    }
}
