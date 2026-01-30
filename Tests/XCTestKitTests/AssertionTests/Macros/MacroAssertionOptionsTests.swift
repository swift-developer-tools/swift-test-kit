//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKitTestUtilities



internal final class MacroAssertionOptionsTests: XCTestKitCase
{
    func testAssertOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.assert)
    }
    
    
    
    func testAssertTrueOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.true)
    }
    
    
    
    func testAssertFalseOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.false)
    }
    
    
    
    func testAssertEqualOptionsBehavior() throws
    {
        testMacroAssertionOptionsBehavior(.equal)
    }
}
