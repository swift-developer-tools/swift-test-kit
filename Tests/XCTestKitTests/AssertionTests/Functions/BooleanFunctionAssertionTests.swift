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



final class BooleanFunctionAssertionTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    // MARK: - Assert
    
    func testAssertWithTrueExpr() throws
    {
        XCTKAssert(true)
        XCTKAssert(1 == 1)
        XCTKAssert(!false)
    }
    
    
    
    func testAssertWithFalseExpr() throws
    {
        XCTExpectFailure()
        XCTKAssert(false)
    }
    
    
    
    func testAssertFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.assert.name) failed")
        }
        
        XCTKAssert(false)
    }
    
    
    
    func testAssertFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.assert.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssert(false, message)
    }
    
    
    
    func testAssertMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.assert)
    }
    
    
    
    func testAssertMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.assert)
    }
    
    
    
    // MARK: - True
    
    func testAssertTrueWithTrueExpr() throws
    {
        XCTKAssertTrue(true)
        XCTKAssertTrue(1 == 1)
        XCTKAssertTrue(!false)
    }
    
    
    
    func testAssertTrueWithFalseExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertTrue(false)
    }
    
    
    
    func testAssertTrueFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`true`.name) failed")
        }
        
        XCTKAssertTrue(false)
    }
    
    
    
    func testAssertTrueFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`true`.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertTrue(false, message)
    }
    
    
    
    func testAssertTrueWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`true`.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertTrue(try TestError.throwError())
    }
    
    
    
    func testAssertTrueMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.`true`)
    }
    
    
    
    func testAssertTrueMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.`true`)
    }
    
    
    
    // MARK: - False
    
    func testAssertFalseWithFalseExpr() throws
    {
        XCTKAssertFalse(!true)
        XCTKAssertFalse(1 != 1)
        XCTKAssertFalse(false)
    }
    
    
    
    func testAssertFalseWithTrueExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertFalse(true)
    }
    
    
    
    func testAssertFalseFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`false`.name) failed")
        }
        
        XCTKAssertFalse(true)
    }
    
    
    
    func testAssertFalseFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`false`.name) failed")
                && $0.compactDescription.contains(message)
        }
        
        XCTKAssertFalse(true, message)
    }
    
    
    
    func testAssertFalseWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`false`.name) failed")
                && $0.compactDescription.contains("threw error")
        }
        
        XCTKAssertFalse(try TestError.throwError())
    }
    
    
    
    func testAssertFalseMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.`false`)
    }
    
    
    
    func testAssertFalseMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.`false`)
    }
}
