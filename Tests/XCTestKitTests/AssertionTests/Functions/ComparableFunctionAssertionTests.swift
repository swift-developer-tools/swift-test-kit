//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore
@testable import XCTestKit
@testable import XCTestKitTestUtilities



internal final class ComparableFunctionAssertionTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    // MARK: - Greater
    
    func testAssertGreaterWithTrueExpr() throws
    {
        XCTKAssertGreaterThan(1, 0)
        XCTKAssertGreaterThan(0, -1)
        XCTKAssertGreaterThan(2.0, 1.0)
    }
    
    
    
    func testAssertGreaterWithFalseExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertGreaterThan(1, 1)
    }
    
    
    
    func testAssertGreaterFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThan.name) failed"
            )
        }
        
        XCTKAssertGreaterThan(0, 1)
    }
    
    
    
    func testAssertGreaterFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThan.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertGreaterThan(0, 1, message)
    }
    
    
    
    func testAssertGreaterWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThan.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertGreaterThan(1, try expr())
    }
    
    
    
    func testAssertGreaterMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.greaterThan)
    }
    
    
    
    func testAssertGreaterMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.greaterThan)
    }
    
    
    
    // MARK: - Greater equal
    
    func testAssertGreaterEqualWithTrueExpr() throws
    {
        XCTKAssertGreaterThanOrEqual(1, 0)
        XCTKAssertGreaterThanOrEqual(0, -1)
        XCTKAssertGreaterThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertGreaterEqualWithFalseExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertGreaterThanOrEqual(0, 1)
    }
    
    
    
    func testAssertGreaterEqualFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThanOrEqual.name) failed"
            )
        }
        
        XCTKAssertGreaterThanOrEqual(0, 1)
    }
    
    
    
    func testAssertGreaterEqualFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThanOrEqual.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertGreaterThanOrEqual(0, 1, message)
    }
    
    
    
    func testAssertGreaterEqualWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.greaterThanOrEqual.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertGreaterThanOrEqual(1, try expr())
    }
    
    
    
    func testAssertGreaterEqualMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.greaterThanOrEqual)
    }
    
    
    
    func testAssertGreaterEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.greaterThanOrEqual)
    }
    
    
    
    // MARK: - Less equal
    
    func testAssertLessEqualWithTrueExpr() throws
    {
        XCTKAssertLessThanOrEqual(0, 1)
        XCTKAssertLessThanOrEqual(-1, 0)
        XCTKAssertLessThanOrEqual(1.0, 1.0)
    }
    
    
    
    func testAssertLessEqualWithFalseExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertLessThanOrEqual(1, 0)
    }
    
    
    
    func testAssertLessEqualFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThanOrEqual.name) failed"
            )
        }
        
        XCTKAssertLessThanOrEqual(1, 0)
    }
    
    
    
    func testAssertLessEqualFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThanOrEqual.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertLessThanOrEqual(1, 0, message)
    }
    
    
    
    func testAssertLessEqualWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThanOrEqual.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertLessThanOrEqual(1, try expr())
    }
    
    
    
    func testAssertLessEqualMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.lessThanOrEqual)
    }
    
    
    
    func testAssertLessEqualMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.lessThanOrEqual)
    }
    
    
    
    // MARK: - Less
    
    func testAssertLessWithTrueExpr() throws
    {
        XCTKAssertLessThan(0, 1)
        XCTKAssertLessThan(-1, 0)
        XCTKAssertLessThan(1.0, 2.0)
    }
    
    
    
    func testAssertLessWithFalseExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertLessThan(1, 1)
    }
    
    
    
    func testAssertLessFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThan.name) failed"
            )
        }
        
        XCTKAssertLessThan(1, 0)
    }
    
    
    
    func testAssertLessFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThan.name) failed"
            ) && $0.compactDescription.contains(message)
        }
        
        XCTKAssertLessThan(1, 0, message)
    }
    
    
    
    func testAssertLessWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.lessThan.name) failed"
            ) && $0.compactDescription.contains("threw error")
        }
        
        let expr: () throws -> Int = { try TestError.throwError() }
        
        XCTKAssertLessThan(1, try expr())
    }
    
    
    
    func testAssertLessMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.lessThan)
    }
    
    
    
    func testAssertLessMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.lessThan)
    }
}
