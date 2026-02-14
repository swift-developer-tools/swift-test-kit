//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



internal extension TestOptions
{
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its property-based testing options property.
    static func propertyOptions(
        iterations      : Int       = 100,
        maxShrinkSteps  : Int       = 100,
        maxSize         : Int       = 100,
        maxDiscardRatio : Int       = 10,
        seed            : UInt64?   = nil
    ) -> TestOptions
    {
        let propertyOptions = PropertyOptions(
            iterations:         iterations,
            maxShrinkSteps:     maxShrinkSteps,
            maxSize:            maxSize,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               seed
        )
        
        return TestOptions(propertyOptions: propertyOptions)
    }
}
