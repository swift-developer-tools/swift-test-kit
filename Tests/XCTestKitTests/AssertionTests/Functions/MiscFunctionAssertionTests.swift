//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit
@testable import XCTestKitTestUtilities



final class MiscFunctionAssertionTests: XCTestKitCase
{
    func testMessageNotEvaluatedOnSuccess() throws
    {
        var evaluated = false
        
        XCTKAssertTrue(true, { evaluated = true; return "msg" }())
        
        XCTAssertFalse(evaluated)
    }
    
    
    
    func testMessageEvaluatedOnlyOnceOnFailure() throws
    {
        var count = 0
        
        XCTExpectFailure()
        {
            XCTKAssertTrue(false, { count += 1; return "msg" }())
        }
        
        XCTAssertEqual(count, 1)
    }
}
