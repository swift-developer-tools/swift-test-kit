//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The options for property-based testing.
public struct TKPropertyOptions: Equatable, Sendable
{
    /// The number of test iterations.
    ///
    /// The default value is `100`.
    public var iterations       : Int
    
    /// The maximum number of shrink steps per failure.
    ///
    /// The default value is `100`.
    public var maxShrinkSteps   : Int
    
    /// The maximum generation size.
    ///
    /// The default value is `100`.
    ///
    /// - Note: See ``GenerationContext/size`` for more information.
    public var maxSize          : Int
    
    /// The maximum ratio of discarded inputs to successful inputs.
    ///
    /// The default value is `10`.
    ///
    /// When using conditional properties, inputs that do not meet the
    /// preconditions are discarded. If the discard count exceeds
    /// `maxDiscardRatio * iterations`, the test fails with an exhaustion error.
    public var maxDiscardRatio  : Int
    
    /// The seed used to initialize the random number generator.
    ///
    /// The default value is `nil`. When `nil`, a random seed is generated
    /// from the system random number generator. Set this to a specific value
    /// to reproduce a previous failure.
    public var seed             : UInt64?
    
    
    
    /// Initializes a ``TKPropertyOptions`` instance, optionally specifying
    /// values for its properties.
    ///
    /// - Precondition: `iterations`, `maxShrinkSteps`, `maxSize`, and
    /// `maxDiscardRatio` must all be non-negative.
    ///
    /// - Warning: Very large `maxSize` values can cause significant memory
    /// pressure, especially for collection types, which generate up to
    /// `maxSize` elements per iteration.
    public init(
        iterations      : Int       = 100,
        maxShrinkSteps  : Int       = 100,
        maxSize         : Int       = 100,
        maxDiscardRatio : Int       = 10,
        seed            : UInt64?   = nil
    )
    {
        precondition(
            iterations >= 0,
            "iterations must be non-negative"
        )
        
        precondition(
            maxShrinkSteps >= 0,
            "maxShrinkSteps must be non-negative"
        )
        
        precondition(
            maxSize >= 0,
            "maxSize must be non-negative"
        )
        
        precondition(
            maxDiscardRatio >= 0,
            "maxDiscardRatio must be non-negative"
        )
        
        self.iterations         = iterations
        self.maxShrinkSteps     = maxShrinkSteps
        self.maxSize            = maxSize
        self.maxDiscardRatio    = maxDiscardRatio
        self.seed               = seed
    }
}
