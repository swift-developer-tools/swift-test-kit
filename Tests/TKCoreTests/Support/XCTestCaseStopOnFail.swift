//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest



/// Stops an `XCTestCase` after an assertion failure.
internal class XCTestCaseStopOnFail: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
    }
}
