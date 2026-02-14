//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



extension Generator where V : Equatable
{
    /// Validates that output of the generator is deterministic.
    internal func validateDeterminism()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value1  : V     = self.generate(context1)
            let value2  : V     = self.generate(context2)
            
            if
                value1.isNaN,
                value2.isNaN
            {
                continue
            }
            
            XCTAssertEqual(value1, value2)
        }
    }
}
