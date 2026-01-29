//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKitTestUtilities



internal final class MacroAssertionThrowingTests: XCTestKitCase
{
    // MARK: - Boolean
    
    func testAssertFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.assert)
    }
    
    
    
    func testAssertTrueFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.`true`)
    }
    
    
    
    func testAssertFalseFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.`false`)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.`nil`)
    }
    
    
    
    func testAssertNotNilFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.notNil)
    }
    
    
    
    func testUnwrapFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.unwrap)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.equal)
    }
    
    
    
    func testAssertNotEqualFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.notEqual)
    }
    
    
    
    func testAssertIdenticalFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.identical)
    }
    
    
    
    func testAssertNotIdenticalFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.notIdentical)
    }
    
    
    
    func testAssertEqualFloatAccFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertEqualIntAccFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.equalWithAccuracy)
    }
    
    
    
    func testAssertNotEqualFloatAccFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.notEqualWithAccuracy )
    }
    
    
    
    func testAssertNotEqualIntAccFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.notEqualWithAccuracy)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.greaterThan)
    }
    
    
    
    func testAssertGreaterEqualFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.greaterThanOrEqual)
    }
    
    
    
    func testAssertLessEqualFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.lessThan)
    }
    
    
    
    // MARK: - Error
    
    func testAssertNoThrowFailsOnThrow() throws
    {
        testMacroAssertionFailsOnThrow(.noThrow)
    }
}
