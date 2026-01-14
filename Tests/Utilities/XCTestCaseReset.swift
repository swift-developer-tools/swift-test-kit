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



/// Resets the global XCTestKit configuration between test cases.
class XCTestCaseReset: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        XCTKConfig.global = XCTKOptions()
    }
    
    
    
    override func tearDown()
    {
        XCTKConfig.global = XCTKOptions()
        
        super.tearDown()
    }
}
