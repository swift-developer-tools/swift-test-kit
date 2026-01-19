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



/// The base class for testing with XCTest.
///
/// This resets the global XCTestKit configuration between test cases and
/// disables continuation after failure.
class XCTestKitCase: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        XCTKConfig.global       = XCTKOptions()
        continueAfterFailure    = false
    }
    
    
    
    override func tearDown()
    {
        XCTKConfig.global = XCTKOptions()
        
        super.tearDown()
    }
}
