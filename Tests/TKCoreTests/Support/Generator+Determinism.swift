//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitBase



extension Generator where V : Equatable
{
    /// Validates that output of the generator is deterministic.
    internal func validateDeterminism()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                self.generate(context1),
                self.generate(context2)
            )
        }
    }
}
