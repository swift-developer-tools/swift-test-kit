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



internal final class FailFunctionAssertionTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    func testFail() throws
    {
        XCTExpectFailure()
        XCTKFail()
    }
    
    
    
    func testFailFailureFormat() throws
    {
        XCTExpectFailure
        {
            return !$0.compactDescription.contains(AK.fail.name)
        }
        
        XCTKFail()
    }
    
    
    
    func testFailFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(message)
        }
        
        XCTKFail(message)
    }
    
    
    
    func testFailMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.fail)
    }
}
