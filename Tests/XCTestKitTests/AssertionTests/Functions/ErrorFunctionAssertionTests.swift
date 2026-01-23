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



final class ErrorFunctionAssertionTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    // MARK: - Throw
    
    func testAssertThrowsWithThrowingExpr() throws
    {
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertThrowsError(try expr())
    }
    
    
    
    func testAssertThrowsWithNonThrowingExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertThrowsError({ })
    }
    
    
    
    func testAssertThrowsFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.throwsError.name) failed"
            )
        }
        
        XCTKAssertThrowsError({ })
    }
    
    
    
    func testAssertThrowsFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.throwsError.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertThrowsError({ }, message)
    }
    
    
    
    func testAssertThrowsMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.throwsError)
    }
    
    
    
    func testAssertThrowsMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.throwsError)
    }
    
    
    
    // MARK: - No throw
    
    func testAssertNoThrowWithNonThrowingExpr() throws
    {
        XCTKAssertNoThrow({ })
    }
    
    
    
    func testAssertNoThrowWithThrowingExpr() throws
    {
        XCTExpectFailure()

        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertNoThrow(try expr())
    }
    
    
    
    func testAssertNoThrowFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.noThrow.name) failed"
            )
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertNoThrow(try expr())
    }
    
    
    
    func testAssertNoThrowFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.noThrow.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertNoThrow(try expr(), message)
    }
    
    
    
    func testAssertNoThrowMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.noThrow)
    }
    
    
    
    func testAssertNoThrowMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.noThrow)
    }
}
