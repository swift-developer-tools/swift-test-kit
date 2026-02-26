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
@testable import struct TestKitCore.Generator



extension Generator where V : Equatable
{
    /// Asserts that output of the generator is deterministic.
    internal func assertDeterministic()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value1  : V     = self.generate(context1)
            let value2  : V     = self.generate(context2)
            
            if value1.isNaN
            {
                XCTAssertTrue(value2.isNaN)
            }
            else
            {
                XCTAssertEqual(value1, value2)
            }
        }
    }
}
