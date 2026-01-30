//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKitTestUtilities



internal final class FunctionAssertionOptionsTests: XCTestKitCase
{
    func testAssertEqualOptionsBehavior() throws
    {
        testFunctionAssertionOptionsBehavior(.equal)
    }
}
